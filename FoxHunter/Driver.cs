using System;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Quantum.FoxHunter
{
    class Driver
    {
        static void Main(string[] args)
        {
            //using (var qsim = new QuantumSimulator())
            //{
            //    HelloQ.Run(qsim).Wait();
            //}

            Stopwatch sw = new Stopwatch();
            sw.Start();

            using (var sim = new QuantumSimulator())
            {
                var successCount = 0;
                var failCount = 0;

                for(int i=0; i<1000; i++)
                {
                    var result = (Result)(TestStrategy.Run(sim).Result);
                    if(result == Result.Zero) { failCount++; }
                    else { successCount++; }
                }

                Console.WriteLine($"OK:\t{successCount}");
                Console.WriteLine($"Fail:\t{failCount}");
            }

            sw.Stop();

            Console.WriteLine($"Experiment finished. " +
                $"Time spent: {sw.ElapsedMilliseconds/1000} seconds");
            Console.ReadLine();
        }
    }
}