USING Siemens.Simatic.MotionControl.Native;
NAMESPACE Simatic.Ax.LDR
    ///================================================================================
    /// SIEMENS AG
    /// (c)Copyright 2026 All Rights Reserved
    ///--------------------------------------------------------------------------------
    /// Library:       LDR
    /// Tested with:   FW 4.1
    /// Engineering:   SIMATIC AX
    /// Restrictions:  -
    /// Requirements:  S7-1500
    /// Functionality: Reads real-time axis state for cyclic execution
    ///================================================================================
    FUNCTION GetTOCyclicData : typeAxisCyclicData
        VAR_INPUT
            /// Interconnect the axis here
            axis : DB_ANY;
            /// TRUE: Also read position (more expensive)
            requestPosition : BOOL;
        END_VAR

        VAR_TEMP
            tempRefSpeedAxis : REF_TO TO_SpeedAxis;
            tempRefPosAxis : REF_TO TO_PositioningAxis;
            tempRetStruct : typeAxisCyclicData;
        END_VAR

        tempRefSpeedAxis := AsSpeedAxisRef(axis);

        IF (tempRefSpeedAxis <> NULL) THEN
            tempRetStruct.toVelocity := tempRefSpeedAxis^.Velocity;
            tempRetStruct.toAcceleration := tempRefSpeedAxis^.Acceleration;
        ELSE
            tempRetStruct.toVelocity := 0.0;
            tempRetStruct.toAcceleration := 0.0;
        END_IF;

        IF requestPosition THEN
            tempRefPosAxis := AsPositioningAxisRef(axis);
            IF (tempRefPosAxis <> NULL) THEN
                tempRetStruct.toPosition := tempRefPosAxis^.Position;
            END_IF;
        END_IF;

        GetTOCyclicData := tempRetStruct;
    END_FUNCTION
END_NAMESPACE
