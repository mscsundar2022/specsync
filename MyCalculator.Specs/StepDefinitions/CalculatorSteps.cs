using System;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using TechTalk.SpecFlow;

namespace MyCalculator.Specs.StepDefinitions
{
    [Binding]
    public class CalculatorSteps
    {
        private readonly Calculator calculator = new Calculator();

        [Given(@"I have entered (.*) into the calculator")]
        public void GivenIHaveEnteredIntoTheCalculator(int operand)
        {
            calculator.Enter(operand);
        }

        [Given(@"I have entered the following numbers")]
        public void GivenIHaveEnteredTheFollowingNumbers(Table table)
        {
            foreach (var number in table.Rows.Select(r => int.Parse(r["number"])))
            {
                calculator.Enter(number);
            }
        }

        [When(@"I choose add")]
        public void WhenIChooseAdd()
        {
            calculator.Add();
        }

        [When(@"I choose multiply")]
        public void WhenIChooseMultiply()
        {
            calculator.Multiply();
        }

        [Then(@"the result should be (.*)")]
        public void ThenTheResultShouldBe(int expectedResult)
        {
            Assert.AreEqual(expectedResult, calculator.Result);
        }
    }
}
