NAMESPACE Simatic.Ax.LDR
    /// Status codes for LDR function blocks
    TYPE Status : WORD (
        /// No job being currently processed
        NO_CALL := WORD#16#7000,
        /// First call after incoming new job (rising edge 'execute')
        FIRST_CALL := WORD#16#7001,
        /// Subsequent call during active processing
        SUBSEQUENT_CALL := WORD#16#7002,
        /// Execution finished without errors
        EXECUTION_FINISHED := WORD#16#7099,
        /// General error
        GENERAL_ERROR := WORD#16#8000
    );
    END_TYPE
END_NAMESPACE
