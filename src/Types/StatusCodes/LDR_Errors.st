NAMESPACE Simatic.Ax.LDR
    /// Error codes for LDR function blocks
    TYPE Errors : WORD (
        /// Connected MC command reported error
        MC_COMMAND_IN_ERROR := WORD#16#8001,
        /// Invalid Direction value
        MC_DIRECTION_INVALID := WORD#16#8002,
        /// A required dynamics parameter is 0.0 which is not permitted.
        /// MoveAbsolute/MoveRelative: Velocity, Acceleration, or Deceleration.
        /// MoveVelocity: Acceleration or Deceleration (Velocity = 0.0 is allowed).
        MC_INVALID_ZERO_DYNAMICS := WORD#16#8003,
        /// Axis type does not meet minimum requirement
        AXIS_TYPE := WORD#16#8004,
        /// Target position outside modulo boundary (MoveAbsolute only)
        POSITION_OUT_OF_MODULO_BOUNDARY := WORD#16#8005,
        /// MC command was aborted externally
        MC_COMMAND_ABORTED := WORD#16#8006
    );
    END_TYPE
END_NAMESPACE
