require 'mkmf'
require 'open3'
require File.expand_path '../compiler/generic_compiler', __FILE__
require File.expand_path '../compiler/gcc', __FILE__
require File.expand_path '../compiler/clang', __FILE__

module Libv8
  module Compiler
    KNOWN_COMPILERS = [
                       'c++',
                       'g++48', 'g++46', 'g++44', 'g++',
                       'clang++',
                      ]

    module_function

    def system_compilers
      available_compilers *Compiler::KNOWN_COMPILERS
    end

    def available_compilers(*compiler_names)
      compiler_paths = compiler_names.map { |name| find name }.reject &:nil?
    end

    def find(name)
      return nil if name.empty?
      path, _, status = capture3 "which #{name}"
      path.to_s.chomp!
      determine_type(path).new(path) if status.success?
    end

    def determine_type(compiler_path)
      compiler_version = capture3("#{compiler_path} -v")[0..1].join

      case compiler_version
      when /\bclang\b/i then Clang
      when /^gcc/i      then GCC
      else                   GenericCompiler
      end
    end

    def capture3(cmd)
      if Open3.respond_to?(:capture3)
        return Open3.capture3(cmd)
      end
      stdout = `#{cmd}`
      [ stdout, '', $? ]
    end


  end
end
