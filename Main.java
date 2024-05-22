import java.io.*;

public class Main {

    public static void main(String[] args) {
        String inputFile = "input.txt";

        try (BufferedReader br = new BufferedReader(new FileReader(inputFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (!line.trim().isEmpty() && !line.trim().startsWith("#")) {
                    try {
                        String machineCode = convertToMachineCode(line.trim());
                        System.out.println(machineCode);
                    } catch (IllegalArgumentException e) {
                        System.err.println("Error: " + e.getMessage() + " in line: " + line);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static String convertToMachineCode(String mipsInstruction) {
        String[] parts = mipsInstruction.split("[,\\s()]+");
        String opcode = parts[0];

        String binaryCode;
        switch (opcode) {
            case "add":
            case "sub":
            case "and":
            case "or":
            case "nand":
            case "xor":
            case "slt":
            case "brv":
            case "jmxor":
                binaryCode = handleRTypeInstruction(parts);
                break;
            case "lw":
            case "sw":
            case "beq":
            case "nandi":
            case "blezal":
            case "jalpc":
                binaryCode = handleITypeInstruction(parts);
                break;
            case "balv":
                binaryCode = handleJTypeInstruction(parts);
                break;
            default:
                throw new IllegalArgumentException("Unsupported instruction: " + opcode);
        }

        return binaryToHex(binaryCode);
    }

    private static String handleRTypeInstruction(String[] parts) {
        if (parts.length < 2) {
            throw new IllegalArgumentException("Invalid R-type instruction");
        }

        String opcode = "000000";
        String rs = "00000";
        String rt = "00000";
        String rd = "00000";
        String shamt = "00000";
        String funct = getFunctionCode(parts[0]);

        if (parts[0].equals("brv")) {
            rs = getRegisterCode(parts[1]);
        } else if (parts[0].equals("jmxor")) {
            if (parts.length < 3) {
                throw new IllegalArgumentException("Invalid R-type instruction");
            }
            rs = getRegisterCode(parts[1]);
            rt = getRegisterCode(parts[2]);
        } else if (parts.length >= 4) {
            rd = getRegisterCode(parts[1]);
            rs = getRegisterCode(parts[2]);
            rt = getRegisterCode(parts[3]);
        } else {
            throw new IllegalArgumentException("Invalid R-type instruction");
        }

        return opcode + rs + rt + rd + shamt + funct;
    }

    private static String handleITypeInstruction(String[] parts) {
        if (parts.length < 3) {
            throw new IllegalArgumentException("Invalid I-type instruction");
        }

        String opcode = getOpcode(parts[0]);
        String rs = "00000";
        String rt = "00000";
        String offset = "0000000000000000";

        if (parts[0].equals("lw") || parts[0].equals("sw")) {
            rt = getRegisterCode(parts[1]);
            offset = String.format("%16s", Integer.toBinaryString(Integer.parseInt(parts[2]))).replace(' ', '0');
            rs = getRegisterCode(parts[3]);
        } else if (parts[0].equals("blezal") || parts[0].equals("jalpc")) {
            rs = getRegisterCode(parts[1]);
            offset = String.format("%16s", Integer.toBinaryString(Integer.parseInt(parts[2]))).replace(' ', '0');
        } else {
            rt = getRegisterCode(parts[1]);
            rs = getRegisterCode(parts[2]);
            offset = String.format("%16s", Integer.toBinaryString(Integer.parseInt(parts[3]))).replace(' ', '0');
        }

        return opcode + rs + rt + offset;
    }

    private static String handleJTypeInstruction(String[] parts) {
        if (parts.length < 2) {
            throw new IllegalArgumentException("Invalid J-type instruction");
        }

        String opcode = getOpcode(parts[0]);
        String address = String.format("%26s", Integer.toBinaryString(Integer.parseInt(parts[1]))).replace(' ', '0');
        return opcode + address;
    }

    private static String getOpcode(String mnemonic) {
        switch (mnemonic) {
            case "lw":
                return "100011";
            case "sw":
                return "101011";
            case "beq":
                return "000100";
            case "nandi":
                return "010000";
            case "blezal":
                return "100100";
            case "jalpc":
                return "011111";
            case "balv":
                return "100000";
            default:
                return "000000";  // R-type instructions and unsupported opcodes
        }
    }

    private static String getFunctionCode(String mnemonic) {
        switch (mnemonic) {
            case "add":
                return "100000";
            case "sub":
                return "100010";
            case "and":
                return "100100";
            case "or":
                return "100101";
            case "nand":
                return "101000";
            case "xor":
                return "100110";
            case "slt":
                return "101010";
            case "brv":
                return "010100";
            case "jmxor":
                return "100110";  // Assuming the function code for jmxor is 100110
            default:
                throw new IllegalArgumentException("Unsupported function code: " + mnemonic);
        }
    }

    private static String getRegisterCode(String register) {
        switch (register) {
            case "$zero":
                return "00000";
            case "$t0":
                return "01000";
            case "$t1":
                return "01001";
            case "$t2":
                return "01010";
            case "$t3":
                return "01011";
            case "$t4":
                return "01100";
            case "$t5":
                return "01101";
            case "$t6":
                return "01110";
            case "$t7":
                return "01111";
            case "$s0":
                return "10000";
            case "$s1":
                return "10001";
            case "$s2":
                return "10010";
            case "$s3":
                return "10011";
            case "$s4":
                return "10100";
            case "$s5":
                return "10101";
            case "$s6":
                return "10110";
            case "$s7":
                return "10111";
            default:
                throw new IllegalArgumentException("Unsupported register: " + register);
        }
    }

    private static String binaryToHex(String binaryCode) {
        int decimal = Integer.parseUnsignedInt(binaryCode, 2);
        return String.format("%08X", decimal);
    }
}
