class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Statements
      def on_program(statements)
        program = statements.to_program(src, filename)
        program << Ruby::Token.new('', position, pop_context) unless stack.context.empty?
        program
      end

      def on_body_stmt(body, rescue_block, else_block, ensure_block)
        statements = [rescue_block, else_block, ensure_block].compact
        body = body.to_chained_block(nil, statements) if rescue_block || ensure_block
        body
      end

      def on_paren(node)
        node = Ruby::Statements.new(node) if node.is_a?(Ruby::Hash)
        node.rdelim ||= pop_token(:@rparen)
        node.ldelim ||= pop_token(:@lparen)
        node
      end

      def on_stmts_add(target, statement)
        target.elements << statement if statement
        target
      end

      def on_stmts_new
        Ruby::Statements.new
      end

      def on_void_stmt
        nil
      end

      def on_var_ref(ref)
        ref.instance_of?(Ruby::Identifier) ? Ruby::Variable.new(ref.token, ref.position, ref.context) : ref
      end

      def on_const_ref(const)
        const
      end

      def on_var_field(field)
        field
      end
    end
  end
end