USING Siemens.Simatic.MotionControl.Native;
USING System.Conversion;
USING System.FastMath;
NAMESPACE Simatic.Ax.LDR
    ///================================================================================
    /// SIEMENS AG
    /// (c)Copyright 2026 All Rights Reserved
    ///--------------------------------------------------------------------------------
    /// Library:       LDR
    /// Tested with:   FW 4.1
    /// Engineering:   SIMATIC AX
    /// Restrictions:  Should be called before the MC_MoveRelative block
    /// Requirements:  S7-1500
    /// Functionality: Calculation of interface signals for MC_MoveRelative to achieve
    ///                a dynamic reversal move without v=a=0
    ///================================================================================
    FUNCTION_BLOCK CalcMoveRelative
        VAR_INPUT
            /// Interconnect the axis here
            axis : DB_ANY;
            /// Rising edge: Starts the calculation of the Dynamic Reversal Move
            execute : BOOL;
            /// [Unit of TO] See MC_MoveRelative. Signed - direction from sign
            distance : LREAL;
            /// [Unit of TO] See MC_MoveRelative. Must be > 0.0 or -1.0 (use default). 0.0 not allowed
            velocity : LREAL := -1.0;
            /// [Unit of TO] See MC_MoveRelative
            acceleration : LREAL := -1.0;
            /// [Unit of TO] See MC_MoveRelative
            deceleration : LREAL := -1.0;
            /// [Unit of TO] See MC_MoveRelative
            jerk : LREAL := -1.0;
            /// Interconnect the Output of the MC_Command.Busy here
            mcOutputBusy : BOOL;
            /// Interconnect the Output of the MC_Command.CommandAborted here
            mcOutputCommandAborted : BOOL;
            /// Interconnect the Output of the MC_Command.Error here
            mcOutputError : BOOL;
        END_VAR

        {S7.Extern := 'ReadOnly'}
        VAR_OUTPUT
            /// TRUE: Motion command reversed and command generation completed
            done : BOOL;
            /// TRUE: Function block active - motion calculation in progress
            busy : BOOL;
            /// TRUE: An error occurred during the execution of the FB
            error : BOOL;
            /// Further status information
            status : WORD := Status#NO_CALL;
            /// Connected to MC_MoveRelative.Execute input parameter
            mcExecute : BOOL;
            /// Connected to MC_MoveRelative.Distance input parameter
            mcDistance : LREAL;
            /// Connected to MC_MoveRelative.Velocity input parameter
            mcVelocity : LREAL := -1.0;
            /// Connected to MC_MoveRelative.Acceleration input parameter
            mcAcceleration : LREAL := -1.0;
            /// Connected to MC_MoveRelative.Deceleration input parameter
            mcDeceleration : LREAL := -1.0;
            /// Connected to MC_MoveRelative.Jerk input parameter
            mcJerk : LREAL := -1.0;
        END_VAR

        VAR
            _internal : typeInternal;
            _mainStateOld : FbState := FbState#NO_PROCESSING;
            _mainState : FbState := FbState#NO_PROCESSING;
            _mainStateEntry : BOOL;
            _positiveToNegativeTransition : BOOL;
            _negativeToPositiveTransition : BOOL;
            _dynamicProfilePossibleToBringZeroToTargetV : BOOL;
            _dynamicProfilePossibleToBringVToZero : BOOL;
            _aMaxStandardAfterZero : LREAL;
            _aMaxStandardBeforeZero : LREAL;
            _effectiveMcTargetJerk : LREAL;
            _effectiveMcTargetDeceleration : LREAL;
            _effectiveMcTargetAcceleration : LREAL;
            _effectiveMcTargetVelocity : LREAL;
            _absoluteDistanceToTarget : LREAL;
            _distanceToBringVToZeroDynamic : LREAL;
            _distanceToBringVToZero : LREAL;
            _distanceAccelFromZeroDynamic : LREAL;
            _distanceAccelFromZero : LREAL;
            _minDistanceAfterZeroCross : LREAL;
            _totalRequiredDistanceDynamic : LREAL;
            _totalRequiredDistance : LREAL;
            _jerkTime : LREAL;
            _accelReachedVelocity : LREAL;
            _startPosition : LREAL;
            _remainingDistance : LREAL;
            _finalDirectionPositive : BOOL;
            _previousPosition : LREAL;
            _cumulativeDistanceTraveled : LREAL;
        END_VAR

        VAR_TEMP
            tempExecute : BOOL;
            tempAxisStartupData : typeAxisStartupData;
            tempAxisCyclicData : typeAxisCyclicData;
            tempPositionDelta : LREAL;
        END_VAR

        VAR CONSTANT
            PRECISION_FACTOR : LREAL := 100.0;
        END_VAR

        // --- TRIGGERING ---
        tempExecute := execute;
        IF (tempExecute = TRUE) AND (_internal.executePrevious = FALSE)
            AND (_internal.output.status = Status#NO_CALL)
        THEN
            // --- INIT ---
            _internal.output.done := FALSE;
            _internal.output.busy := TRUE;
            _internal.output.error := FALSE;
            _internal.output.mcExecute := FALSE;
            _internal.output.mcDistance := 0.0;
            _internal.output.mcVelocity := 0.0;
            _internal.output.mcAcceleration := 0.0;
            _internal.output.mcDeceleration := 0.0;
            _internal.output.mcJerk := 0.0;

            tempAxisStartupData := GetTOStartupData(axis := axis);
            _internal.input.toDefaultVelocity := tempAxisStartupData.toDefaultVelocity;
            _internal.input.toDefaultAcceleration := tempAxisStartupData.toDefaultAcceleration;
            _internal.input.toDefaultDeceleration := tempAxisStartupData.toDefaultDeceleration;
            _internal.input.toDefaultJerk := tempAxisStartupData.toDefaultJerk;
            _internal.input.toMaxVelocity := tempAxisStartupData.toMaxVelocity;
            _internal.input.toMaxAcceleration := tempAxisStartupData.toMaxAcceleration;
            _internal.input.toMaxDeceleration := tempAxisStartupData.toMaxDeceleration;
            _internal.input.toMaxJerk := tempAxisStartupData.toMaxJerk;
            _internal.input.toVelocity := tempAxisStartupData.toVelocity;
            _internal.input.toModuloEnabled := tempAxisStartupData.toModuloEnabled;
            _internal.input.toModuloLength := tempAxisStartupData.toModuloLength;
            _internal.input.toModuloStartvalue := tempAxisStartupData.toModuloStartvalue;
            _internal.input.mcTargetDistance := distance;
            _internal.input.mcTargetVelocity := velocity;
            _internal.input.mcTargetAcceleration := acceleration;
            _internal.input.mcTargetDeceleration := deceleration;
            _internal.input.mcTargetJerk := jerk;
            _internal.input.typeOfTO := tempAxisStartupData.typeOfTO;
            _absoluteDistanceToTarget := ABS(_internal.input.mcTargetDistance);
            _distanceToBringVToZero := 0.0;
            _distanceAccelFromZero := 0.0;
            _minDistanceAfterZeroCross := 0.0;
            _totalRequiredDistance := 0.0;
            _jerkTime := 0.0;
            _accelReachedVelocity := 0.0;
            _dynamicProfilePossibleToBringVToZero := FALSE;
            _dynamicProfilePossibleToBringZeroToTargetV := FALSE;

            //Capture start position for cumulative distance tracking
            _startPosition := tempAxisStartupData.toPosition;
            _previousPosition := _startPosition;
            _cumulativeDistanceTraveled := 0.0;
            _remainingDistance := _internal.input.mcTargetDistance;

            // --- CHECK INVALID INPUT ---
            IF _internal.input.typeOfTO <= 1 THEN
                _internal.output.status := Errors#AXIS_TYPE;
            END_IF;

            //Velocity check - magnitude only, < 0.0 means use TO default
            IF _internal.input.mcTargetVelocity >= _internal.input.toMaxVelocity THEN
                IF (_internal.output.status AND WORD#16#8000) <> WORD#16#8000 THEN
                    _internal.output.status := Warnings#MC_TARGET_VELOCITY_EXCEEDS_MAX;
                END_IF;
                _internal.input.mcTargetVelocity := _internal.input.toMaxVelocity;
                _effectiveMcTargetVelocity := _internal.input.mcTargetVelocity;
            ELSIF _internal.input.mcTargetVelocity = 0.0 THEN
                _internal.output.status := Errors#MC_INVALID_ZERO_DYNAMICS;
            ELSIF _internal.input.mcTargetVelocity < 0.0 THEN
                _effectiveMcTargetVelocity := _internal.input.toDefaultVelocity;
            ELSE
                _effectiveMcTargetVelocity := _internal.input.mcTargetVelocity;
            END_IF;

            //Apply direction sign based on Distance sign
            IF _internal.input.mcTargetDistance < 0.0 THEN
                _effectiveMcTargetVelocity := - ABS(_effectiveMcTargetVelocity);
            ELSE
                _effectiveMcTargetVelocity := ABS(_effectiveMcTargetVelocity);
            END_IF;

            //Acceleration check
            IF _internal.input.mcTargetAcceleration >= _internal.input.toMaxAcceleration THEN
                IF (_internal.output.status AND WORD#16#8000) <> WORD#16#8000 THEN
                    _internal.output.status := Warnings#MC_TARGET_ACCELERATION_EXCEEDS_MAX;
                END_IF;
                _internal.input.mcTargetAcceleration := _internal.input.toMaxAcceleration;
                _effectiveMcTargetAcceleration := _internal.input.toMaxAcceleration;
            ELSIF _internal.input.mcTargetAcceleration = 0.0 THEN
                _internal.output.status := Errors#MC_INVALID_ZERO_DYNAMICS;
            ELSIF _internal.input.mcTargetAcceleration < 0.0 THEN
                _effectiveMcTargetAcceleration := _internal.input.toDefaultAcceleration;
            ELSE
                _effectiveMcTargetAcceleration := _internal.input.mcTargetAcceleration;
            END_IF;

            //Deceleration check
            IF _internal.input.mcTargetDeceleration >= _internal.input.toMaxDeceleration THEN
                IF (_internal.output.status AND WORD#16#8000) <> WORD#16#8000 THEN
                    _internal.output.status := Warnings#MC_TARGET_DECELERATION_EXCEEDS_MAX;
                END_IF;
                _internal.input.mcTargetDeceleration := _internal.input.toMaxDeceleration;
                _effectiveMcTargetDeceleration := _internal.input.toMaxDeceleration;
            ELSIF _internal.input.mcTargetDeceleration = 0.0 THEN
                _internal.output.status := Errors#MC_INVALID_ZERO_DYNAMICS;
            ELSIF _internal.input.mcTargetDeceleration < 0.0 THEN
                _effectiveMcTargetDeceleration := _internal.input.toDefaultDeceleration;
            ELSE
                _effectiveMcTargetDeceleration := _internal.input.mcTargetDeceleration;
            END_IF;

            //Jerk check
            IF _internal.input.mcTargetJerk >= _internal.input.toMaxJerk THEN
                IF (_internal.input.mcTargetJerk = 0.0) OR (_internal.input.toMaxJerk = 0.0) THEN
                    _internal.input.mcTargetJerk := 0.0;
                    _effectiveMcTargetJerk := 1.0e+12;
                ELSE
                    IF (_internal.output.status AND WORD#16#8000) <> WORD#16#8000 THEN
                        _internal.output.status := Warnings#MC_TARGET_JERK_EXCEEDS_MAX;
                    END_IF;
                    _internal.input.mcTargetJerk := _internal.input.toMaxJerk;
                END_IF;
            ELSIF _internal.input.mcTargetJerk < 0.0 THEN
                _effectiveMcTargetJerk := _internal.input.toDefaultJerk;
            ELSE
                _effectiveMcTargetJerk := _internal.input.mcTargetJerk;
            END_IF;

            IF _internal.output.status = Status#NO_CALL THEN
                _internal.output.status := Status#FIRST_CALL;
            END_IF;

            // --- Calculate braking distance first (needed for overshoot detection) ---
            IF (ABS(_internal.input.toVelocity) > 0.0) AND (_effectiveMcTargetDeceleration > 0.0) AND (_effectiveMcTargetJerk > 0.0) THEN
                _jerkTime := _effectiveMcTargetDeceleration / _effectiveMcTargetJerk;
                _accelReachedVelocity := 0.5 * _effectiveMcTargetJerk * _jerkTime * _jerkTime;
                IF ABS(_internal.input.toVelocity) <= _accelReachedVelocity THEN
                    _distanceToBringVToZero := (2.0 / 3.0) * ABS(_internal.input.toVelocity) * SQRT(2.0 * ABS(_internal.input.toVelocity) / _effectiveMcTargetJerk);
                ELSE
                    _distanceToBringVToZero := (ABS(_internal.input.toVelocity) * ABS(_internal.input.toVelocity) / (2.0 * _effectiveMcTargetDeceleration)) + (_effectiveMcTargetDeceleration * ABS(_internal.input.toVelocity) / (2.0 * _effectiveMcTargetJerk));
                END_IF;
            END_IF;

            // --- Detect velocity transitions (including overshoot) ---
            _positiveToNegativeTransition := (_internal.input.toVelocity > 0) AND (_internal.input.mcTargetDistance < 0) AND (_internal.input.mcTargetJerk <> 0);
            _negativeToPositiveTransition := (_internal.input.toVelocity < 0) AND (_internal.input.mcTargetDistance > 0) AND (_internal.input.mcTargetJerk <> 0);

            //Overshoot: moving negative, distance negative, braking distance > |distance|
            IF (_internal.input.toVelocity < 0) AND (_internal.input.mcTargetDistance < 0)
                AND (_distanceToBringVToZero > ABS(_internal.input.mcTargetDistance))
                AND (_internal.input.mcTargetJerk <> 0)
            THEN
                _negativeToPositiveTransition := TRUE;
            END_IF;
            //Overshoot: moving positive, distance positive, braking distance > distance
            IF (_internal.input.toVelocity > 0) AND (_internal.input.mcTargetDistance > 0)
                AND (_distanceToBringVToZero > _internal.input.mcTargetDistance)
                AND (_internal.input.mcTargetJerk <> 0)
            THEN
                _positiveToNegativeTransition := TRUE;
            END_IF;

            //Determine final direction after reversal
            IF _negativeToPositiveTransition THEN
                _finalDirectionPositive := TRUE;
            ELSIF _positiveToNegativeTransition THEN
                _finalDirectionPositive := FALSE;
            ELSE
                _finalDirectionPositive := (_internal.input.mcTargetDistance > 0.0);
            END_IF;

            // --- FEASIBILITY CHECK ---
            IF (_positiveToNegativeTransition OR _negativeToPositiveTransition) AND (_effectiveMcTargetJerk > 0.0) THEN
                //Deceleration phase profile flags
                IF (ABS(_internal.input.toVelocity) > 0.0) AND (_effectiveMcTargetDeceleration > 0.0) THEN
                    IF ABS(_internal.input.toVelocity) <= _accelReachedVelocity THEN
                        _dynamicProfilePossibleToBringVToZero := FALSE;
                    ELSE
                        _distanceToBringVToZeroDynamic := _distanceToBringVToZero / 2.0;
                        _dynamicProfilePossibleToBringVToZero := TRUE;
                    END_IF;
                END_IF;

                //Distance to accelerate from zero to target velocity
                IF (ABS(_effectiveMcTargetVelocity) > 0.0) AND (_effectiveMcTargetAcceleration > 0.0) AND (_effectiveMcTargetDeceleration > 0.0) THEN
                    _jerkTime := _effectiveMcTargetAcceleration / _effectiveMcTargetJerk;
                    _accelReachedVelocity := 0.5 * _effectiveMcTargetJerk * _jerkTime * _jerkTime;
                    IF ABS(_effectiveMcTargetVelocity) <= _accelReachedVelocity THEN
                        _distanceAccelFromZero := (2.0 / 3.0) * ABS(_effectiveMcTargetVelocity) * SQRT(2.0 * ABS(_effectiveMcTargetVelocity) / _effectiveMcTargetJerk);
                        _dynamicProfilePossibleToBringZeroToTargetV := FALSE;
                    ELSE
                        _distanceAccelFromZero := (ABS(_effectiveMcTargetVelocity) * ABS(_effectiveMcTargetVelocity) / (2.0 * _effectiveMcTargetAcceleration)) + (_effectiveMcTargetAcceleration * ABS(_effectiveMcTargetVelocity) / (2.0 * _effectiveMcTargetJerk));
                        _distanceAccelFromZeroDynamic := _distanceAccelFromZero / 2.0;
                        _dynamicProfilePossibleToBringZeroToTargetV := TRUE;
                    END_IF;
                ELSE
                    _distanceAccelFromZero := 0.0;
                END_IF;

                _totalRequiredDistance := _distanceToBringVToZero + _distanceAccelFromZero;
                _totalRequiredDistanceDynamic := _distanceToBringVToZeroDynamic + _distanceAccelFromZeroDynamic;

                IF NOT _dynamicProfilePossibleToBringZeroToTargetV OR NOT _dynamicProfilePossibleToBringVToZero THEN
                    IF _internal.output.status < WORD#16#7500 THEN
                        _internal.output.status := Warnings#NO_DYNAMIC_REVERSAL_POSSIBLE;
                    END_IF;
                END_IF;
            END_IF;

            // --- INIT STATE SELECTION ---
            IF (_internal.output.status AND WORD#16#8000) = WORD#16#8000 THEN
                _mainState := FbState#NO_PROCESSING;
            ELSIF _internal.output.status = Warnings#NO_DYNAMIC_REVERSAL_POSSIBLE THEN
                _mainState := FbState#PROCESSING_THIRD_JERK_LIMITATION;
            ELSIF (_positiveToNegativeTransition OR _negativeToPositiveTransition) THEN
                _mainState := FbState#PROCESSING_FIRST_JERK_LIMITATION;
            ELSE
                IF _effectiveMcTargetJerk = 0.0 THEN
                    _internal.output.status := Warnings#NO_DYNAMIC_REVERSAL_NEEDED_TRAPEZOID_CHOSEN;
                ELSE
                    _internal.output.status := Warnings#NO_REVERSAL_NEEDED;
                END_IF;
                _mainState := FbState#PROCESSING_THIRD_JERK_LIMITATION;
            END_IF;
        ELSIF (_internal.output.status = Status#FIRST_CALL) THEN
            _internal.output.status := Status#SUBSEQUENT_CALL;
        END_IF;
        _internal.executePrevious := tempExecute;

        // --- CYCLIC ---
        IF (_internal.output.status = Status#NO_CALL) THEN
            RETURN;
        END_IF;
        IF (_internal.output.status > Status#NO_CALL) AND (_internal.output.status < Status#GENERAL_ERROR) THEN
            tempAxisCyclicData := GetTOCyclicData(axis := axis, requestPosition := TRUE);
            _internal.input.toVelocity := tempAxisCyclicData.toVelocity;
            _internal.input.toAcceleration := tempAxisCyclicData.toAcceleration;
            _internal.input.toPosition := tempAxisCyclicData.toPosition;

            //Cumulative distance tracking for remaining distance
            IF NOT (_internal.output.status = Warnings#NO_REVERSAL_NEEDED)
                AND NOT (_internal.output.status = Warnings#NO_DYNAMIC_REVERSAL_POSSIBLE)
                AND NOT (_internal.output.status = Warnings#NO_DYNAMIC_REVERSAL_NEEDED_TRAPEZOID_CHOSEN)
            THEN
                tempPositionDelta := _internal.input.toPosition - _previousPosition;

                //Unwrap delta for modulo axes based on velocity direction
                IF _internal.input.toModuloEnabled AND (_internal.input.toModuloLength > 0.0) THEN
                    IF (_internal.input.toVelocity > 0.0) AND (tempPositionDelta < (- _internal.input.toModuloLength / 2.0)) THEN
                        tempPositionDelta := tempPositionDelta + _internal.input.toModuloLength;
                    ELSIF (_internal.input.toVelocity < 0.0) AND (tempPositionDelta > (_internal.input.toModuloLength / 2.0)) THEN
                        tempPositionDelta := tempPositionDelta - _internal.input.toModuloLength;
                    END_IF;
                END_IF;

                _cumulativeDistanceTraveled := _cumulativeDistanceTraveled + tempPositionDelta;
                _remainingDistance := _internal.input.mcTargetDistance - _cumulativeDistanceTraveled;
                _previousPosition := _internal.input.toPosition;
            END_IF;

            _internal.input.mcOutputBusy := mcOutputBusy;
            _internal.input.mcOutputError := mcOutputError;
            _internal.input.mcOutputCommandAborted := mcOutputCommandAborted;
            IF _internal.input.mcOutputCommandAborted THEN
                _internal.output.status := Errors#MC_COMMAND_ABORTED;
                _mainState := FbState#NO_PROCESSING;
            END_IF;
            IF _mainStateOld <> _mainState THEN
                _mainStateEntry := TRUE;
            ELSE
                _mainStateEntry := FALSE;
            END_IF;
            _mainStateOld := _mainState;
        END_IF;

        // --- STATE MACHINE ---
        CASE _mainState OF
            FbState#NO_PROCESSING:
                ;

            FbState#PROCESSING_FIRST_JERK_LIMITATION:
                _internal.output.mcDistance := _internal.input.mcTargetDistance;
                _internal.output.mcVelocity := _internal.input.mcTargetVelocity;
                _internal.output.mcAcceleration := _internal.input.mcTargetAcceleration;
                _internal.output.mcDeceleration := _internal.input.mcTargetDeceleration;
                _internal.output.mcJerk := _internal.input.mcTargetJerk;
                _internal.output.mcExecute := TRUE;

                IF _internal.input.mcOutputError THEN
                    _internal.output.mcExecute := FALSE;
                    _internal.output.status := Errors#MC_COMMAND_IN_ERROR;
                END_IF;

                IF _internal.input.mcOutputBusy
                    AND _internal.output.mcExecute
                    AND NOT _mainStateEntry
                THEN
                    _mainState := FbState#PROCESSING_SECOND_CROSSING_ZERO_VELOCITY;
                END_IF;

            FbState#PROCESSING_SECOND_CROSSING_ZERO_VELOCITY:
                //Check if already crossed zero (strict inequality)
                IF (_positiveToNegativeTransition AND (_internal.input.toVelocity < 0))
                    OR (_negativeToPositiveTransition AND (_internal.input.toVelocity > 0))
                THEN
                    _mainState := FbState#PROCESSING_THIRD_JERK_LIMITATION;
                    RETURN;
                END_IF;

                IF _mainStateEntry THEN
                    _internal.output.mcExecute := FALSE;
                ELSE
                    IF _positiveToNegativeTransition THEN
                        IF ROUND(_internal.input.toAcceleration * PRECISION_FACTOR) = ROUND(- _effectiveMcTargetDeceleration * PRECISION_FACTOR)
                        THEN
                            _internal.output.mcDistance := _remainingDistance;
                            _internal.output.mcVelocity := _internal.input.mcTargetVelocity;
                            _internal.output.mcAcceleration := _internal.input.mcTargetAcceleration;
                            _internal.output.mcDeceleration := _internal.input.mcTargetDeceleration;
                            _internal.output.mcJerk := 0.0;
                            _internal.output.mcExecute := TRUE;
                        END_IF;
                    ELSIF _negativeToPositiveTransition THEN
                        IF ROUND(_internal.input.toAcceleration * PRECISION_FACTOR) = ROUND(_effectiveMcTargetAcceleration * PRECISION_FACTOR)
                        THEN
                            _internal.output.mcDistance := _remainingDistance;
                            _internal.output.mcVelocity := _internal.input.mcTargetVelocity;
                            _internal.output.mcAcceleration := _internal.input.mcTargetAcceleration;
                            _internal.output.mcDeceleration := _internal.input.mcTargetDeceleration;
                            _internal.output.mcJerk := 0.0;
                            _internal.output.mcExecute := TRUE;
                        END_IF;
                    END_IF;
                END_IF;

                IF _internal.input.mcOutputError THEN
                    _internal.output.mcExecute := FALSE;
                    _internal.output.status := Errors#MC_COMMAND_IN_ERROR;
                END_IF;

                IF _internal.input.mcOutputBusy
                    AND _internal.output.mcExecute
                    AND NOT _mainStateEntry
                THEN
                    _mainState := FbState#PROCESSING_THIRD_JERK_LIMITATION;
                END_IF;

            FbState#PROCESSING_THIRD_JERK_LIMITATION:
                IF _mainStateEntry
                    AND NOT (_internal.output.status = Warnings#NO_REVERSAL_NEEDED)
                    AND NOT (_internal.output.status = Warnings#NO_DYNAMIC_REVERSAL_POSSIBLE)
                    AND NOT (_internal.output.status = Warnings#NO_DYNAMIC_REVERSAL_NEEDED_TRAPEZOID_CHOSEN)
                THEN
                    _internal.output.mcExecute := FALSE;
                ELSE
                    IF (_positiveToNegativeTransition AND (_internal.input.toVelocity < 0)) OR
                        (_negativeToPositiveTransition AND (_internal.input.toVelocity > 0)) OR
                        (_internal.output.status = Warnings#NO_REVERSAL_NEEDED) OR
                        (_internal.output.status = Warnings#NO_DYNAMIC_REVERSAL_POSSIBLE) OR
                        (_internal.output.status = Warnings#NO_DYNAMIC_REVERSAL_NEEDED_TRAPEZOID_CHOSEN)
                    THEN
                        _internal.output.mcDistance := _remainingDistance;
                        _internal.output.mcVelocity := _internal.input.mcTargetVelocity;
                        _internal.output.mcAcceleration := _internal.input.mcTargetAcceleration;
                        _internal.output.mcDeceleration := _internal.input.mcTargetDeceleration;
                        _internal.output.mcJerk := _internal.input.mcTargetJerk;
                        _internal.output.mcExecute := TRUE;
                    END_IF;

                    IF _internal.input.mcOutputError THEN
                        _internal.output.mcExecute := FALSE;
                        _internal.output.status := Errors#MC_COMMAND_IN_ERROR;
                    END_IF;

                    IF _internal.input.mcOutputBusy
                        AND _internal.output.mcExecute
                        AND NOT _mainStateEntry
                    THEN
                        _internal.output.status := Status#EXECUTION_FINISHED;
                    END_IF;
                END_IF;
            ELSE
                ; //Unexpected state
        END_CASE;

        // --- OUTPUTS ---
        IF (_internal.output.status = Status#EXECUTION_FINISHED) AND (_internal.output.done = FALSE) THEN
            _internal.output.done := TRUE;
            _internal.output.busy := FALSE;
            _internal.output.error := FALSE;
            _mainState := FbState#NO_PROCESSING;
        ELSIF ((_internal.output.status AND WORD#16#8000) = WORD#16#8000) AND (_internal.output.error = FALSE) THEN
            _internal.output.done := FALSE;
            _internal.output.busy := FALSE;
            _internal.output.error := TRUE;
            _mainState := FbState#NO_PROCESSING;
        ELSIF (tempExecute = FALSE) AND ((_internal.output.done = TRUE) OR (_internal.output.error = TRUE)) THEN
            _internal.output.done := FALSE;
            _internal.output.busy := FALSE;
            _internal.output.error := FALSE;
            _internal.output.status := Status#NO_CALL;
            _internal.output.mcExecute := FALSE;
            _internal.output.mcDistance := 0.0;
            _internal.output.mcVelocity := -1.0;
            _internal.output.mcAcceleration := -1.0;
            _internal.output.mcDeceleration := -1.0;
            _internal.output.mcJerk := -1.0;
        END_IF;

        done := _internal.output.done;
        busy := _internal.output.busy;
        error := _internal.output.error;
        status := _internal.output.status;
        mcExecute := _internal.output.mcExecute;
        mcDistance := _internal.output.mcDistance;
        mcVelocity := _internal.output.mcVelocity;
        mcAcceleration := _internal.output.mcAcceleration;
        mcDeceleration := _internal.output.mcDeceleration;
        mcJerk := _internal.output.mcJerk;
    END_FUNCTION_BLOCK
END_NAMESPACE
