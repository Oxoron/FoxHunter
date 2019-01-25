﻿namespace Quantum.FoxHunter
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    operation HelloQ () : Unit {
        Message("Hello quantum world!");
    }

    operation TestStrategy () : (Result)
    {
        let res = Zero;

        using(qubits=Qubit[16])
        {               
            // 0..4 - holes
            // 5 - current movement direction. Zero means "go down", One means "go up"
            // 6 - Game status. 1 means "fox is free, go further"
            // 7,8,9,10, 11 - movements history

            InitFoxHoles(qubits);           

            ResetAll(qubits); // ALWAYS clean after yourself        
        }                               
        return Zero;
    }

    // Inits fox holes, with almost equal probabilities
    operation InitFoxHoles(register: Qubit[]) : Unit
    {
        body
        {
            ResetAll(register);

            // See schema
            //  https://algassert.com/quirk#circuit={%22cols%22:[[%22H%22,1,%22H%22],[%22%E2%80%A2%22,1,%22%E2%80%A2%22,%22X%22],[%22%E2%97%A6%22,%22X%22,%22%E2%97%A6%22],[%22X%22,1,%22X%22,%22%E2%80%A2%22],[1,1,1,%22%E2%80%A2%22,%22H%22],[1,1,1,%22X%22,%22%E2%80%A2%22]]}
            //

            // Step 1
            H(register[0]);
            H(register[2]);
            
            // Step 2
            (Controlled (X))([register[0],register[2]], register[3]);               

            // Step 3
            X(register[0]);
            X(register[2]);
            (Controlled (X))([register[0],register[2]], register[3]);               
            X(register[0]);
            X(register[2]);

            // Step 4
            CNOT(register[3], register[0]);
            CNOT(register[3], register[2]);    

            // Step 5
            (Controlled (H))([register[3]], register[4]);

            // Step 6
            CNOT(register[4], register[3]);
        }               
    }
}