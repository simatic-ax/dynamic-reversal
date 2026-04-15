NAMESPACE Simatic.Ax.LDR
    /// Block internal data
    TYPE typeInternal : STRUCT
        /// Edge detection for execute input
        executePrevious : BOOL;
        /// Snapshot of all inputs and TO data
        input : typeInternalInputs;
        /// Calculated MC command parameters and FB status
        output : typeInternalOutputs;
    END_STRUCT;
    END_TYPE
END_NAMESPACE
