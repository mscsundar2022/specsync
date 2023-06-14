using System.Collections.Generic;

namespace MyCalculator.Specs
{
    /// <summary>
    /// Basic calculator implementation that fulfills the specs
    /// </summary>
    public class Calculator
    {
        private readonly Stack<int> operands = new Stack<int>();

        public int Result => operands.Peek();

        public void Enter(int operand)
        {
            operands.Push(operand);
        }

        public void Add()
        {
            operands.Push(operands.Pop() + operands.Pop());
        }

        public void Multiply()
        {
            operands.Push(operands.Pop() * operands.Pop());
        }
    }
}
