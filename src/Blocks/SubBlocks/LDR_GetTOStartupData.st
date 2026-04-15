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
    /// Functionality: Reads axis configuration from Technology Object DB_ANY reference
    ///================================================================================
    FUNCTION GetTOStartupData : typeAxisStartupData
        VAR_INPUT
            /// Interconnect the axis here
            axis : DB_ANY;
        END_VAR

        VAR_TEMP
            tempRefSpeedAxis : REF_TO TO_SpeedAxis;
            tempRefPosAxis : REF_TO TO_PositioningAxis;
            tempRefSyncAxis : REF_TO TO_SynchronousAxis;
            tempRetStruct : typeAxisStartupData;
        END_VAR

        VAR CONSTANT
            SPEED_AXIS_TYPE : USINT := USINT#1;
            POSITIONING_AXIS_TYPE : USINT := USINT#2;
            SYNCHRONOUS_AXIS_TYPE : USINT := USINT#3;
            INVALID_AXIS_TYPE : USINT := USINT#0;
        END_VAR

        tempRefSpeedAxis := AsSpeedAxisRef(axis);

        IF (tempRefSpeedAxis <> NULL) THEN
            //Assignment successful --> DB_ANY is at least a Speed axis
            tempRetStruct.typeOfTO := SPEED_AXIS_TYPE;
            tempRetStruct.toDefaultVelocity := tempRefSpeedAxis^.DynamicDefaults.Velocity;
            tempRetStruct.toDefaultAcceleration := tempRefSpeedAxis^.DynamicDefaults.Acceleration;
            tempRetStruct.toDefaultDeceleration := tempRefSpeedAxis^.DynamicDefaults.Deceleration;
            tempRetStruct.toDefaultJerk := tempRefSpeedAxis^.DynamicDefaults.Jerk;
            tempRetStruct.toMaxVelocity := tempRefSpeedAxis^.DynamicLimits.MaxVelocity;
            tempRetStruct.toMaxAcceleration := tempRefSpeedAxis^.DynamicLimits.MaxAcceleration;
            tempRetStruct.toMaxDeceleration := tempRefSpeedAxis^.DynamicLimits.MaxDeceleration;
            tempRetStruct.toMaxJerk := tempRefSpeedAxis^.DynamicLimits.MaxJerk;
            tempRetStruct.toVelocity := tempRefSpeedAxis^.Velocity;

            tempRefPosAxis := AsPositioningAxisRef(axis);
            IF (tempRefPosAxis <> NULL) THEN
                //Assignment successful --> DB_ANY is at least a Positioning axis
                tempRetStruct.typeOfTO := POSITIONING_AXIS_TYPE;
                tempRetStruct.toPosition := tempRefPosAxis^.Position;
                IF tempRefPosAxis^.Modulo.Enable THEN
                    tempRetStruct.toModuloEnabled := tempRefPosAxis^.Modulo.Enable;
                    tempRetStruct.toModuloStartvalue := tempRefPosAxis^.Modulo.StartValue;
                    tempRetStruct.toModuloLength := tempRefPosAxis^.Modulo.Length;
                ELSE
                    tempRetStruct.toModuloEnabled := FALSE;
                    tempRetStruct.toModuloStartvalue := 0.0;
                    tempRetStruct.toModuloLength := 0.0;
                END_IF;
                tempRefSyncAxis := AsSynchronousAxisRef(axis);
                IF tempRefSyncAxis <> NULL THEN
                    //Assignment successful --> DB_ANY is a Synchronous axis
                    tempRetStruct.typeOfTO := SYNCHRONOUS_AXIS_TYPE;
                END_IF;
            ELSE
                //Data are not available/relevant for TO_SpeedAxis
                tempRetStruct.toModuloEnabled := FALSE;
                tempRetStruct.toModuloStartvalue := 0.0;
                tempRetStruct.toModuloLength := 0.0;
                tempRetStruct.toPosition := 0.0;
            END_IF;
        ELSE
            //Invalid DB_ANY
            tempRetStruct.typeOfTO := INVALID_AXIS_TYPE;
        END_IF;

        GetTOStartupData := tempRetStruct;
    END_FUNCTION
END_NAMESPACE
