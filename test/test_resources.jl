using SimJulia
using Base.Test

function generator(env::Environment, res::Resource, preempt::Bool)
  id = 100
  while true
    id -= 1
    yield(timeout(env, rand()))
    Process(env, handling, res, id, preempt)
  end
end

function handling(env::Environment, res::Resource, id::Int64, preempt::Bool)
  try
    println("Number $id requests handling at time $(now(env))")
    yield(request(res, id, preempt))
    println("Number $id starts handling at time $(now(env))")
    yield(timeout(env, 2.25*rand()))
    println("Number $id stops handling at time $(now(env))")
    yield(release(res))
    println("Number $id is released at time $(now(env))")
  catch exc
    println(exc)
    println("Number $id request is interrupted at time $(now(env)) by $(cause(exc))")
  end

end

env = Environment()
res = Resource(env)
Process(env, generator, res, false)
run(env, 2.0)
env2 = Environment(2.0)
res2 = Resource(env2, 2)
Process(env2, generator, res2, true)
run(env2, 8.0)
