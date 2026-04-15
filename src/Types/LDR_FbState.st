NAMESPACE Simatic.Ax.LDR
    /// State machine states for LDR function blocks
    TYPE FbState : (
        /// No processing active
        NO_PROCESSING,
        /// Phase 1: Initial deceleration with normal dynamics
        PROCESSING_FIRST_JERK_LIMITATION,
        /// Phase 2: Zero crossing with infinite jerk
        PROCESSING_SECOND_CROSSING_ZERO_VELOCITY,
        /// Phase 3: After zero crossing, restore normal dynamics
        PROCESSING_THIRD_JERK_LIMITATION
    ) := NO_PROCESSING;
    END_TYPE
END_NAMESPACE
