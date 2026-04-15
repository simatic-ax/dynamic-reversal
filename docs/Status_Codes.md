# Status Codes

All LDR function blocks report their state through the `status` output (type `WORD`). The status codes are organized into three typed enumerations in the `Simatic.Ax.LDR` namespace.

## Status Codes (`Status`)

Processing status codes indicating the current state of the function block.

| Named Value | Hex Value | Description |
| ----------- | --------- | ----------- |
| `Status#NO_CALL` | `16#7000` | No job is being processed. Ready for new `execute` rising edge. |
| `Status#FIRST_CALL` | `16#7001` | First call after rising edge of `execute`. Initialization complete. |
| `Status#SUBSEQUENT_CALL` | `16#7002` | Processing active, cyclic calculation in progress. |
| `Status#EXECUTION_FINISHED` | `16#7099` | Execution completed successfully. Final MC command has been issued. |
| `Status#GENERAL_ERROR` | `16#8000` | General error threshold (used internally for error detection). |

## Warning Codes (`Warnings`)

Warning codes indicate that the function block completed but dynamic reversal was not applied. The motion is still executed using a standard profile.

| Named Value | Hex Value | Description | Applicable Blocks |
| ----------- | --------- | ----------- | ----------------- |
| `Warnings#MC_TARGET_VELOCITY_EXCEEDS_MAX` | `16#7501` | Velocity was clamped to TO maximum. | All |
| `Warnings#MC_TARGET_ACCELERATION_EXCEEDS_MAX` | `16#7502` | Acceleration was clamped to TO maximum. | All |
| `Warnings#MC_TARGET_DECELERATION_EXCEEDS_MAX` | `16#7503` | Deceleration was clamped to TO maximum. | All |
| `Warnings#MC_TARGET_JERK_EXCEEDS_MAX` | `16#7504` | Jerk was clamped to TO maximum. | All |
| `Warnings#NO_REVERSAL_NEEDED` | `16#750A` | No direction change detected. Current velocity is already in the target direction. | All |
| `Warnings#NO_DYNAMIC_REVERSAL_POSSIBLE` | `16#750B` | Dynamic reversal not possible. Either insufficient distance or triangular profile detected. | All |
| `Warnings#NO_DYNAMIC_REVERSAL_NEEDED_TRAPEZOID_CHOSEN` | `16#750C` | Jerk = 0.0 was specified. Trapezoid profile used (already dynamic). | All |

## Error Codes (`Errors`)

Error codes indicate that the function block could not process the request. The `error` output is TRUE and no MC command is issued.

| Named Value | Hex Value | Description | Applicable Blocks |
| ----------- | --------- | ----------- | ----------------- |
| `Errors#MC_COMMAND_IN_ERROR` | `16#8001` | The connected MC command reported an error. Check the MC instruction for details. | All |
| `Errors#MC_DIRECTION_INVALID` | `16#8002` | Invalid `direction` value. CalcMoveAbsolute: must be 1, 2, or 3. CalcMoveVelocity: must be 0, 1, or 2. | CalcMoveAbsolute, CalcMoveVelocity |
| `Errors#MC_INVALID_ZERO_DYNAMICS` | `16#8003` | A required dynamics parameter is 0.0. CalcMoveAbsolute/CalcMoveRelative: velocity, acceleration, or deceleration. CalcMoveVelocity: acceleration or deceleration (velocity = 0.0 is allowed). | All |
| `Errors#AXIS_TYPE` | `16#8004` | Axis type does not meet the minimum requirement. CalcMoveVelocity: requires at least TO_SpeedAxis. CalcMoveAbsolute/CalcMoveRelative: requires at least TO_PositioningAxis. | All |
| `Errors#POSITION_OUT_OF_MODULO_BOUNDARY` | `16#8005` | Target position is outside the configured modulo range. | CalcMoveAbsolute |
| `Errors#MC_COMMAND_ABORTED` | `16#8006` | The MC command was aborted externally (e.g., by MC_Halt). No further commands will be issued until the next `execute` rising edge. | All |

## Status Code Ranges

The status code value ranges follow the SIMATIC convention:

| Range | Category | Error Output |
| ----- | -------- | --- |
| `16#7000 – 16#74FF` | Status (normal processing) | FALSE |
| `16#7500 – 16#7FFF` | Warnings (completed with limitations) | FALSE |
| `16#8000 – 16#FFFF` | Errors (processing failed) | TRUE |

The error bit (bit 15) can be used to programmatically distinguish errors from status/warnings:
