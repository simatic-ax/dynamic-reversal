NAMESPACE Simatic.Ax.LDR
    /// Technology object data to be read once
    TYPE typeAxisStartupData : STRUCT
        /// SPEED_AXIS_TYPE (1), POSITIONING_AXIS_TYPE (2), SYNCHRONOUS_AXIS_TYPE (3), INVALID_AXIS_TYPE (0)
        typeOfTO : USINT;
        /// Axis is modulo axis
        toModuloEnabled : BOOL;
        /// Start value of modulo range
        toModuloStartvalue : LREAL;
        /// Length of modulo range
        toModuloLength : LREAL;
        /// Default setpoint velocity
        toDefaultVelocity : LREAL;
        /// Default setpoint acceleration
        toDefaultAcceleration : LREAL;
        /// Default setpoint deceleration
        toDefaultDeceleration : LREAL;
        /// Default setpoint jerk
        toDefaultJerk : LREAL;
        /// Velocity limit
        toMaxVelocity : LREAL;
        /// Acceleration limit
        toMaxAcceleration : LREAL;
        /// Deceleration limit
        toMaxDeceleration : LREAL;
        /// Jerk limit
        toMaxJerk : LREAL;
        /// Technology object position
        toPosition : LREAL;
        /// Technology object velocity
        toVelocity : LREAL;
    END_STRUCT;
    END_TYPE
END_NAMESPACE
