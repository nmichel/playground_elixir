defmodule StatelessCounter do
    defstruct counter: 0
end

defimpl Enumerable, for: StatelessCounter do
    def count(_enumerable) do
        {:error, __MODULE__}
    end

    def member?(%StatelessCounter{counter: counter}, element) when is_integer(element) and element >= counter do
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
    def reduce(enumerable = %StatelessCounter{counter: counter}, {:cont, acc}, fun) do
        reduce(%StatelessCounter{enumerable | counter: counter+1}, fun.(counter, acc), fun)
    end
end

