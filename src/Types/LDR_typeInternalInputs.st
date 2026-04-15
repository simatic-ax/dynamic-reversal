NAMESPACE Simatic.Ax.LDR
    /// Data from the technology object, user requested targets and feedback from the Motion Control instruction's outputs
    TYPE typeInternalInputs : STRUCT
        /// Absolute target position (MoveAbsolute)
        mcTargetPosition : LREAL := 0.0;
        /// Distance for the positioning (MoveRelative)
        mcTargetDistance : LREAL := 0.0;
        /// Velocity setpoint, concrete behavior depends on MC instruction
        mcTargetVelocity : LREAL := -1.0;
        /// > 0.0: the specified value is used | 0.0: not permitted | < 0.0: Dynamic default is used
        mcTargetAcceleration : LREAL := -1.0;
        /// > 0.0: the specified value is used | 0.0: not permitted | < 0.0: Dynamic default is used
        mcTargetDeceleration : LREAL := -1.0;
        /// >0.0: constant acceleration velocity profile | 0.0: Trapezoid velocity profile | <0.0: Dynamic default is used
        mcTargetJerk : LREAL := 1.0;
        /// Target direction
        mcTargetDirection : INT := 1;
        /// Connection from MC instruction output 'Busy'
        mcOutputBusy : BOOL := FALSE;
        /// Connection from MC instruction output 'Error'
        mcOutputError : BOOL := FALSE;
        /// Connection from MC instruction output 'CommandAborted'
        mcOutputCommandAborted : BOOL := FALSE;
        /// Axis is modulo axis
        toModuloEnabled : BOOL := FALSE;
        /// Start value of modulo range
        toModuloStartvalue : LREAL := 0.0;
        /// Length of modulo range
        toModuloLength : LREAL := 0.0;
        /// Default setpoint velocity
        toDefaultVelocity : LREAL := 0.0;
        /// Default setpoint acceleration
        toDefaultAcceleration : LREAL := 0.0;
        /// Default setpoint deceleration
        toDefaultDeceleration : LREAL := 0.0;
        /// Default setpoint jerk
        toDefaultJerk : LREAL := 0.0;
        /// Velocity limit
        toMaxVelocity : LREAL := 0.0;
        /// Acceleration limit
        toMaxAcceleration : LREAL := 0.0;
        /// Deceleration limit
        toMaxDeceleration : LREAL := 0.0;
        /// Jerk limit
        toMaxJerk : LREAL := 0.0;
        /// Technology object position
        toPosition : LREAL := 0.0;
        /// Technology object velocity
        toVelocity : LREAL := 0.0;
        /// Technology object acceleration
        toAcceleration : LREAL := 0.0;
        /// SPEED_AXIS_TYPE (1), POSITIONING_AXIS_TYPE (2), SYNCHRONOUS_AXIS_TYPE (3), INVALID_AXIS_TYPE (0)
        typeOfTO : USINT := USINT#0;
    END_STRUCT;
    END_TYPE
END_NAMESPACE
