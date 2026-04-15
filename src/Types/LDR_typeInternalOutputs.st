NAMESPACE Simatic.Ax.LDR
    /// Outputs to indicate LDR status and interact with Motion Control instructions inputs
    TYPE typeInternalOutputs : STRUCT
        /// TRUE: Dynamic reversal is finished
        done : BOOL := FALSE;
        /// TRUE: Function block is activated
        busy : BOOL := FALSE;
        /// TRUE: An error has occurred during operation
        error : BOOL := FALSE;
        /// Further status information (default: STATUS_NO_CALL)
        status : WORD := WORD#16#7000;
        /// Connection to MC instruction input 'Execute'
        mcExecute : BOOL := FALSE;
        /// Connection to MC instruction input 'Position' (MoveAbsolute)
        mcPosition : LREAL := 0.0;
        /// Connection to MC instruction input 'Distance' (MoveRelative)
        mcDistance : LREAL := 0.0;
        /// Connection to MC instruction input 'Velocity'
        mcVelocity : LREAL := -1.0;
        /// Connection to MC instruction input 'Acceleration'
        mcAcceleration : LREAL := -1.0;
        /// Connection to MC instruction input 'Deceleration'
        mcDeceleration : LREAL := -1.0;
        /// Connection to MC instruction input 'Jerk'
        mcJerk : LREAL := -1.0;
        /// Connection to MC instruction input 'Direction' (MoveAbsolute, MoveVelocity)
        mcDirection : INT := 1;
    END_STRUCT;
    END_TYPE
END_NAMESPACE
