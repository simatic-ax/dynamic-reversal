NAMESPACE Simatic.Ax.LDR
    /// Warning codes for the main LDR function blocks
    TYPE Warnings : WORD(
        /// Velocity clamped to TO maximum dynamics
        MC_TARGET_VELOCITY_EXCEEDS_MAX  := WORD#16#7501,
        /// Acceleration clamped to TO maximum dynamics
        MC_TARGET_ACCELERATION_EXCEEDS_MAX  := WORD#16#7502,
        /// Deceleration clamped to TO maximum dynamics
        MC_TARGET_DECELERATION_EXCEEDS_MAX  := WORD#16#7503,
        /// Jerk clamped to TO maximum dynamics
        MC_TARGET_JERK_EXCEEDS_MAX  := WORD#16#7504,
        /// No direction change detected
        NO_REVERSAL_NEEDED  := WORD#16#750A,
        /// Insufficient distance or dynamics for dynamic reversal
        NO_DYNAMIC_REVERSAL_POSSIBLE  := WORD#16#750B,
        /// Jerk = 0.0 selected, trapezoid profile used
        NO_DYNAMIC_REVERSAL_NEEDED_TRAPEZOID_CHOSEN  := WORD#16#750C
    );
    END_TYPE
END_NAMESPACE
