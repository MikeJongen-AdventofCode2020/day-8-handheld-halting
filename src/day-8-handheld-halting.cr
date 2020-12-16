require "option_parser"
require "benchmark"
require "string_scanner"

file_name = ""
benchmark = false

OptionParser.parse do |parser|
  parser.banner = "Welcome to Report Repair"

  parser.on "-f FILE", "--file=FILE", "Input file" do |file|
    file_name = file
  end
  parser.on "-b", "--benchmark", "Measure benchmarks" do
    benchmark = true
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

unless file_name.empty?
  data = File.read_lines(file_name)

  code = [] of Instruction
  data.each do |input|
    code << Instruction.new(input)
  end
  puts "code size: #{code.size}"

  pc = 0
  acc = 0
  previous_instructions = [] of Int32
  until previous_instructions.includes? pc
    previous_instructions << pc
    pc, acc = code[pc].run(pc, acc)
  end

  puts "acc before last unique instruction: #{acc}"
  
  code.each do |instruction|
    next if instruction.instruction == "acc"
    if instruction.instruction == "jmp"
      instruction.change("nop") 
    elsif instruction.instruction == "nop"
      instruction.change("jmp")
    end

    pc = 0
    acc = 0
    previous_instructions = [] of Int32
    until (previous_instructions.includes? pc) || (pc >= code.size) || (pc < 0)
      previous_instructions << pc
      pc, acc = code[pc].run(pc, acc)
    end
    puts "acc: #{acc} at end of program" if pc == code.size

    if instruction.instruction == "jmp"
      instruction.change("nop") 
    elsif instruction.instruction == "nop"
      instruction.change("jmp")
    end
  end

end

class Instruction
  @jmp = 1
  @acc = 0
  @value = 0
  getter instruction = ""

  def initialize(input : String)
    @value = input[4..-1].to_i
    @instruction = input[0..2]
    @acc = @value if input[0..2] == "acc"
    @jmp = @value if input[0..2] == "jmp"
  end

  def run(pc : Int32, acc : Int32)
    pc += @jmp
    acc += @acc
    return pc, acc
  end

  def change(instruction : String)
    @jmp = 1
    @acc = 0
    @acc = @value if instruction == "acc"
    @jmp = @value if instruction == "jmp"  
    @instruction = instruction
  end
end