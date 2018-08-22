defmodule Tuto.YTest do
  use ExUnit.Case

  test "list length computation by explicit nesting" do
    # t :: list -> int
    # make_rec :: t -> t
    make_rec =
      fn length ->
        fn
          [] ->
            0
          [_h | t] ->
            1 + length.(t)
        end
      end

    fail =
      fn _ ->
        raise "FAILED"
      end

    assert (make_rec.(fail)).([]) == 0
    assert (make_rec.(make_rec.(fail))).([1]) == 1
    assert_raise RuntimeError, fn ->
      (make_rec.(make_rec.(fail))).([1, 2]) == 2
    end
  end

  test "anonymous list length computation by explicit nesting" do
    fail =
      fn _ ->
        raise "FAILED"
      end

    length4 = 
      (fn make_rec ->
        fail
        |> make_rec.()
        |> make_rec.()
        |> make_rec.()
        |> make_rec.()
      end).(
        fn length ->
          fn
            [] -> 0
            [_h | t] -> 1 + length.(t)
          end
        end)

    assert length4.([]) == 0
    assert length4.([1]) == 1
    assert length4.([1, 2]) == 2
    assert length4.([1, 2, 3]) == 3
  end

  test "generative list length computation" do
    # t :: t -> (list -> int)
    # meta :: t -> (list -> int)
    # 
    # meta =
    #   fn f ->
    #     f.(f)
    #   end

    length =
      (fn make_rec ->
        make_rec.(make_rec)
      end).(
        fn recur ->
          fn
            [] -> 0
            # Note: expression (recur.recur()) only depends on input parameter function,
            # hence the next variation where it is reduced to a function call
            [_h | t] -> 1 + (recur.(recur)).(t)
          end
        end)

    assert length.([]) == 0
    assert length.([1]) == 1
    assert length.([1, 2]) == 2
    assert length.([1, 2, 3]) == 3
    assert length.([1, 2, 3, 4]) == 4
  end

  test "generative list length computation no recur.(recur)" do
    length =
      (fn make_rec ->
        make_rec.(make_rec)
      end).(
        fn recur ->
          # Note: the same way, the following function body has no bindings except on its parameter
          # therefore it can be "uplifted" and provided as a parameter of the surrounding function;
          # hence the next iteration.
          (fn length ->
            fn
              []      -> 0
              [_h | t] -> 1 + length.(t)
            end
          end).(
            # Note: as stated in previous iteration,
            # the recursion form is extracted and passed as parameter.
            fn t ->
              (recur.(recur)).(t)
            end)
        end)

    assert length.([]) == 0
    assert length.([1]) == 1
    assert length.([1, 2]) == 2
    assert length.([1, 2, 3]) == 3
    assert length.([1, 2, 3, 4]) == 4
  end

  test "uplifted length function" do
    length =
      (fn length ->
        (fn make_rec ->
          make_rec.(make_rec)
        end).(
          fn recur ->
            length.(
              fn t ->
                (recur.(recur)).(t)
              end)
          end)
      end).(
        fn length ->
          fn
            []      -> 0
            [_h | t] -> 1 + length.(t)
          end
        end)

    assert length.([]) == 0
    assert length.([1]) == 1
    assert length.([1, 2]) == 2
    assert length.([1, 2, 3]) == 3
    assert length.([1, 2, 3, 4]) == 4
  end

  test "Y combinator length" do
    alias Tuto.Y

    length =
      Y.y(fn
        length ->
          fn
            []      -> 0
            [_h | t] -> 1 + length.(t)
          end
        end)

    assert length.([]) == 0
    assert length.([1]) == 1
    assert length.([1, 2]) == 2
    assert length.([1, 2, 3]) == 3
    assert length.([1, 2, 3, 4]) == 4
  end

  test "Y combinator fib" do
    alias Tuto.Y

    fib =
      Y.y(fn
        fib ->
          fn
            0 -> 0
            1 -> 1
            n -> fib.(n-1) + fib.(n-2)
          end
        end)

    assert fib.(0) == 0
    assert fib.(1) == 1
    assert fib.(2) == 1
    assert fib.(3) == 2
    assert fib.(4) == 3
    assert fib.(5) == 5
    assert fib.(6) == 8
  end

  test "Y combinator qsort" do
    alias Tuto.Y

    qsort =
      Y.y(fn
        qsort ->
          fn
            [] -> []
            [h|t] -> qsort.(Enum.filter(t, &Kernel.<=(&1, h))) ++ [h] ++ qsort.(Enum.filter(t, &Kernel.>(&1, h)))
          end
        end)

    data = 
    (fn -> Enum.random(1..100) end)
    |> Stream.repeatedly
    |> Enum.take(100)

    assert qsort.(data) == Enum.sort(data)
  end
end
