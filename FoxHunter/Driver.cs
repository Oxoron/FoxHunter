using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Quantum.FoxHunter
{
    class Driver
    {
        static void Main(string[] args)
        {
            RunFoxHunt();

            //TestInitiation();
            //TestMovementDirectionSetup();
            //TestFirstMove();
            //TestMovements();

            Console.ReadLine();
            
        }

        static void TestInitiation()
        {
            using (var sim = new QuantumSimulator())
            {
                var initedQubitsValues = Enumerable.Range(0, 5)
                    .ToDictionary(qubitIndex => qubitIndex, oneMesaured => 0);


                for (int i = 0; i < 1000; i++)
                {
                    (Result, Result, Result, Result, Result) result = TestInit.Run(sim).Result;
                    if (result.Item1 == Result.One) { initedQubitsValues[0]++; }
                    if (result.Item2 == Result.One) { initedQubitsValues[1]++; }
                    if (result.Item3 == Result.One) { initedQubitsValues[2]++; }
                    if (result.Item4 == Result.One) { initedQubitsValues[3]++; }
                    if (result.Item5 == Result.One) { initedQubitsValues[4]++; }
                }

                Console.WriteLine($"Qubit-0 initiations: {initedQubitsValues[0]}");
                Console.WriteLine($"Qubit-1 initiations: {initedQubitsValues[1]}");
                Console.WriteLine($"Qubit-2 initiations: {initedQubitsValues[2]}");
                Console.WriteLine($"Qubit-3 initiations: {initedQubitsValues[3]}");
                Console.WriteLine($"Qubit-4 initiations: {initedQubitsValues[4]}");
            }
        }

        static void TestMovementDirectionSetup()
        {
            using (var sim = new QuantumSimulator())
            {
                List<string> results = new List<string>();
                string initedCubit = null;
                string moveDirection = null;

                for (int i = 0; i < 1000; i++)
                {
                    (Result, Result, Result, Result, Result, Result) result = Quantum.FoxHunter.TestMovementDirectionSetup.Run(sim).Result;
                    if (result.Item1 == Result.One) { initedCubit = "0"; }
                    if (result.Item2 == Result.One) { initedCubit = "1"; }
                    if (result.Item3 == Result.One) { initedCubit = "2"; }
                    if (result.Item4 == Result.One) { initedCubit = "3"; }
                    if (result.Item5 == Result.One) { initedCubit = "4"; }

                    if (result.Item6 == Result.One) { moveDirection = "1"; }
                    else { moveDirection = "0"; }

                    results.Add($"{initedCubit}{moveDirection}");
                }

                foreach(var group in results
                    .GroupBy(result => result)
                    .OrderBy(group => group.Key))
                {
                    Console.WriteLine($"{group.Key} hole was measured {group.Count()} times");
                }
                
                Console.WriteLine($"\r\nTotal measures: {results.Count()}");                                  
            }
        }

        static void TestFirstMove()
        {                
            using (var sim = new QuantumSimulator())
            {
                List<string> results = new List<string>();
                string initedCubit = null;
                string moveDirection = null;

                for (int i = 0; i < 1000; i++)
                {
                    (Result, Result, Result, Result, Result, Result) result = Quantum.FoxHunter.TestFirstMovement.Run(sim).Result;
                    if (result.Item1 == Result.One) { initedCubit = "0"; }
                    if (result.Item2 == Result.One) { initedCubit = "1"; }
                    if (result.Item3 == Result.One) { initedCubit = "2"; }
                    if (result.Item4 == Result.One) { initedCubit = "3"; }
                    if (result.Item5 == Result.One) { initedCubit = "4"; }

                    if (result.Item6 == Result.One) { moveDirection = "1"; }
                    else { moveDirection = "0"; }

                    results.Add($"{initedCubit}{moveDirection}");
                }

                // Holes measurements
                foreach (var group in results
                    .GroupBy(result => result[0])
                    .OrderBy(group => group.Key))
                {
                    Console.WriteLine($"{group.Key} hole was measured {group.Count()} times");
                }

                // Directions measuremetns
                foreach (var group in results
                    .GroupBy(result => result[1])
                    .OrderBy(group => group.Key))
                {
                    Console.WriteLine($"{group.Key} direction was measured {group.Count()} times");
                }

                Console.WriteLine($"\r\nTotal measures: {results.Count()}");
            }

        }

        static void TestMovements()
        {
            using (var sim = new QuantumSimulator())
            {
                int zerosCount = 0;

                for (int i = 0; i < 1000; i++)
                {
                    Result result = Quantum.FoxHunter.TestSixMovements.Run(sim).Result;
                    if(result == Result.Zero) { zerosCount++; }
                }                                                                                                       

                Console.WriteLine($"\r\nTotal zeroes: {zerosCount}");
            }

        }

        static void RunFoxHunt()
        {
            Stopwatch sw = new Stopwatch();
            sw.Start();

            using (var sim = new QuantumSimulator())
            {
                var foxSurvives = 0;
                var hunterWins = 0;

                for (int i = 0; i < 1000; i++)
                {
                    var result = (Result)(TestStrategy.Run(sim).Result);
                    if (result == Result.Zero) { foxSurvives++; }
                    else { hunterWins++; }
                }

                Console.WriteLine($"Fox survives: \t{foxSurvives}");
                Console.WriteLine($"Hunter wins: \t{hunterWins}");
            }

            sw.Stop();

            Console.WriteLine($"Experiment finished. " +
                $"Time spent: {sw.ElapsedMilliseconds / 1000} seconds");            
        }
    }
}