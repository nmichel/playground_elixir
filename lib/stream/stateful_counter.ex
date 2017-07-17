defmodule StatefulCounter do
    defstruct base: 0, spit_period_ms: 10, pid: nil

    def new(base \\ 0, spit_period_ms \\ 10)  do
        {:ok, pid} = Agent.start fn -> base end
        %StatefulCounter{base: base, spit_period_ms: spit_period_ms, pid: pid}
    end

    def get(%StatefulCounter{spit_period_ms: spit_period_ms, pid: pid}) do
        :ok = Process.sleep spit_period_ms
        Agent.get pid, fn counter -> counter end
    end

    def get_and_inc(%StatefulCounter{spit_period_ms: spit_period_ms, pid: pid}) do
        :ok = Process.sleep spit_period_ms
        Agent.get_and_update pid, fn counter -> {counter, counter+1} end
    end
end

defimpl Enumerable, for: StatefulCounter do
    def count(_enumerable) do
        {:error, __MODULE__}
    end

    def member?(%StatefulCounter{base: counter}, element) when is_integer(element) and element >= counter do
        {:ok, true}
    end
    def member?(_enumerable, _element) do
        {:ok, false}
    end

    def reduce(_, {:halt, acc}, _fun) do
        {:halted, acc}
    end
    def reduce(enumerable, {:suspend, acc}, fun) do
        {:suspended, acc, &reduce(enumerable, &1, fun)}
    end
    def reduce(enumerable = %StatefulCounter{}, {:cont, acc}, fun) do
        v = StatefulCounter.get_and_inc(enumerable)
        reduce(enumerable, fun.(v, acc), fun)
    end
end
