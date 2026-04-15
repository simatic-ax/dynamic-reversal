NAMESPACE Simatic.Ax.LDR
    /// Technology object data to be read cyclically
    TYPE typeAxisCyclicData : STRUCT
        /// Setpoint velocity of the technology object
        toVelocity : LREAL;
        /// Setpoint acceleration of the technology object
        toAcceleration : LREAL;
        /// Setpoint position of the technology object
        toPosition : LREAL;
    END_STRUCT;
    END_TYPE
END_NAMESPACE
