import uint from std::integer

public final byte CARRY_FLAG     = 0b0000_0001
public final byte ZERO_FLAG      = 0b0000_0010
public final byte NEGATIVE_FLAG  = 0b0000_0100
public final byte OVERFLOW_FLAG  = 0b0000_1000
public final byte SIGN_FLAG      = 0b0001_0000
public final byte HALFCARRY_FLAG = 0b0010_0000
public final byte BITCOPY_FLAG   = 0b0100_0000
public final byte INTERRUPT_FLAG = 0b1000_0000

public type Avr is {
    // Represents the Program Counter which determines what instruction to
    // execute next.
    uint pc,
    // The Status Register contains various flags used, for example, when
    // performing conditional branches.   
    byte sreg,
    // Data space includes the registers, I/O ports and data space.
    byte[] data,
    // Code space represents executable instructions.
    byte[] code
} where |data| == 608 && |code| == 8192

/**
 * Adds two registers without the C Flag and places the result in the
 */
public function executeADD(Avr state, int rd, int rr) -> (Avr nstate):
    state.pc = state.pc + 1
    byte Rd = state.data[rd]
    byte Rr = state.data[rr]
    // Perform operation
    byte R = Rd // BROKEN
    // Update register file
    state.data[rr] = R
    // Set flags
    bool Rd3 = (Rd & 0b1000) != 0b0
    bool Rr3 = (Rr & 0b1000) != 0b0
    bool R3  = (R & 0b1000) != 0b0
    bool Rd7 = (Rd & 0b1000_0000) != 0b0
    bool Rr7 = (Rr & 0b1000_0000) != 0b0
    bool R7  = (R & 0b1000_0000) != 0b0
    //
    bool C = (Rd7 && Rr7) || (Rr7 && !R7) || (!R7 && Rd7)
    bool Z = (R == 0b0)
    bool N = R7
    bool V = (Rd7 && Rr7 && !R7) || (!Rd7 && !Rr7 && R7)
    bool S = (N||V) && (!N||!V) // N ^ V
    bool H = (Rd3 && Rr3) || (Rr3 && !R3) || (!R3 && Rd3)
    bool T = (state.sreg & BITCOPY_FLAG) != 0b0
    bool I = (state.sreg & INTERRUPT_FLAG) != 0b0
    // Done
    return state

/**
 * Loads an 8-bit constant directly to register 16 to 31.
 */
public function executeLDI(Avr state, int rd, byte k) -> (Avr nstate):
  state.pc = state.pc + 1
  state.data[rd] = k
  return state

/**
 * This instruction performs a single cycle No Operation.
 */
public function executeNOP(Avr state) -> (Avr nstate):
   state.pc = state.pc + 1
   return state

