# global registry of all abstract classes defined
abstract_declarations = Dict{Symbol, Array}()

macro _abstract(sym, block)
  abstract_declarations[sym] = [Expr(:(::), var.args[1], var.args[2]) for var in block.args[2:2:end]]

  Expr(:abstract, esc(sym), abstract_declarations)
end

macro _abstracttype(sym, parent, block)
	parent_declarations = abstract_declarations[parent]
	child_declarations = [Expr(:(::), var.args[1], var.args[2]) for var in block.args[2:2:end]]
	declarations = vcat(parent_declarations, child_declarations)

	abstract_declarations[sym] = declarations
	Expr(:abstract, Expr(:<:, esc(sym), esc(parent)), abstract_declarations)
end

macro _type(sym, parent, block)
  parent_declarations = abstract_declarations[parent]
  child_declarations = [Expr(:(::), var.args[1], var.args[2]) for var in block.args[2:2:end]]
  declarations = vcat(parent_declarations, child_declarations)

  Expr(:type, true, Expr(:<:, esc(sym), esc(parent)), Expr(:block, declarations...))
end

macro _immutable(sym, parent, block)
  parent_declarations = abstract_declarations[parent]
  child_declarations = [Expr(:(::), var.args[1], var.args[2]) for var in block.args[2:2:end]]
  declarations = vcat(parent_declarations, child_declarations)

  Expr(:type, false, Expr(:<:, esc(sym), esc(parent)), Expr(:block, declarations...))
end
