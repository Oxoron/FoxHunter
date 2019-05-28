namespace Quantum.FoxHunter
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

            // See circuit
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
            (Controlled (X))([register[0],register[2]], register[1]);               
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



    // Select next Fox movement direction, updating qubit 5
    // 1 means go up   (4 -> 3, 3 -> 2, ... 1 -> 0)
    // 0 means go down (0 -> 1, 1 -> 2, ... 3 -> 4)      
    operation SetupMovementDirection(qubits: Qubit[]) : Unit
    {
        body
        {   
            // See circuit
            //  https://algassert.com/quirk#circuit={%22cols%22:[[%22~27va%22],[1,1,1,1,%22%E2%80%A2%22,%22X%22],[1,1,1,%22%E2%80%A2%22,1,%22H%22],[1,1,%22%E2%80%A2%22,1,1,%22H%22],[1,%22%E2%80%A2%22,1,1,1,%22H%22]],%22gates%22:[{%22id%22:%22~27va%22,%22name%22:%22Init%22,%22circuit%22:{%22cols%22:[[%22H%22,1,%22H%22],[%22%E2%80%A2%22,1,%22%E2%80%A2%22,%22X%22],[%22%E2%97%A6%22,%22X%22,%22%E2%97%A6%22],[%22X%22,1,%22X%22,%22%E2%80%A2%22],[1,1,1,%22%E2%80%A2%22,%22H%22],[1,1,1,%22X%22,%22%E2%80%A2%22]]}},{%22id%22:%22~7vbh%22,%22name%22:%22Set%20Current%20Move%22,%22circuit%22:{%22cols%22:[[1,1,1,1,%22%E2%80%A2%22,%22X%22],[1,1,1,%22%E2%80%A2%22,1,%22H%22],[1,1,%22%E2%80%A2%22,1,1,%22H%22],[1,%22%E2%80%A2%22,1,1,1,%22H%22]]}}]}
            //

            // Step 1
            CNOT(qubits[4], qubits[5]);
            
            // Step 2
            (Controlled (H))([qubits[3]], qubits[5]);               

            // Step 3
            (Controlled (H))([qubits[2]], qubits[5]);               

            // Step 4
            (Controlled (H))([qubits[1]], qubits[5]);               
        }  

        controlled auto;
    }


    // Makes a movement based on the 5'th qubit value
    // 1 means go up   (4 -> 3, 3 -> 2, ... 1 -> 0)
    // 0 means go down (0 -> 1, 1 -> 2, ... 3 -> 4)
    operation MakeMovement(qubits: Qubit[]) : Unit
    {
        body
        {   
            // See circuit
            // https://algassert.com/quirk#circuit={%22cols%22:[[%22~27va%22],[%22~7vbh%22],[%22Swap%22,%22Swap%22,1,1,1,%22%E2%80%A2%22],[1,%22Swap%22,%22Swap%22,1,1,%22%E2%80%A2%22],[1,1,%22Swap%22,%22Swap%22,1,%22%E2%80%A2%22],[1,1,1,%22Swap%22,%22Swap%22,%22%E2%80%A2%22],[1,1,1,%22Swap%22,%22Swap%22,%22%E2%97%A6%22],[1,1,%22Swap%22,%22Swap%22,1,%22%E2%97%A6%22],[1,%22Swap%22,%22Swap%22,1,1,%22%E2%97%A6%22],[%22Swap%22,%22Swap%22,1,1,1,%22%E2%97%A6%22]],%22gates%22:[{%22id%22:%22~27va%22,%22name%22:%22Init%22,%22circuit%22:{%22cols%22:[[%22H%22,1,%22H%22],[%22%E2%80%A2%22,1,%22%E2%80%A2%22,%22X%22],[%22%E2%97%A6%22,%22X%22,%22%E2%97%A6%22],[%22X%22,1,%22X%22,%22%E2%80%A2%22],[1,1,1,%22%E2%80%A2%22,%22H%22],[1,1,1,%22X%22,%22%E2%80%A2%22]]}},{%22id%22:%22~7vbh%22,%22name%22:%22Set%20Current%20Move%22,%22circuit%22:{%22cols%22:[[1,1,1,1,%22%E2%80%A2%22,%22X%22],[1,1,1,%22%E2%80%A2%22,1,%22H%22],[1,1,%22%E2%80%A2%22,1,1,%22H%22],[1,%22%E2%80%A2%22,1,1,1,%22H%22]]}},{%22id%22:%22~jblp%22,%22name%22:%22Move%22,%22circuit%22:{%22cols%22:[[%22Swap%22,%22Swap%22,1,1,1,%22%E2%80%A2%22],[1,%22Swap%22,%22Swap%22,1,1,%22%E2%80%A2%22],[1,1,%22Swap%22,%22Swap%22,1,%22%E2%80%A2%22],[1,1,1,%22Swap%22,%22Swap%22,%22%E2%80%A2%22],[1,1,1,%22Swap%22,%22Swap%22,%22%E2%97%A6%22],[1,1,%22Swap%22,%22Swap%22,1,%22%E2%97%A6%22],[1,%22Swap%22,%22Swap%22,1,1,%22%E2%97%A6%22],[%22Swap%22,%22Swap%22,1,1,1,%22%E2%97%A6%22]]}}]}
            //
            // SwapReverseRegister swaps qubits : https://docs.microsoft.com/en-us/qsharp/api/canon/microsoft.quantum.canon.swapreverseregister?view=qsharp-preview


            // Code movement Up            
                // Step 1
                mutable qubitsToSwap  = [qubits[0], qubits[1]];
                (Controlled(SwapReverseRegister))([qubits[5]],qubitsToSwap);
            
                // Step 2
                set qubitsToSwap  = [qubits[1], qubits[2]];
                (Controlled(SwapReverseRegister))([qubits[5]],qubitsToSwap);           

                // Step 3
                set qubitsToSwap  = [qubits[2], qubits[3]];
                (Controlled(SwapReverseRegister))([qubits[5]],qubitsToSwap);             

                // Step 4
                set qubitsToSwap  = [qubits[3], qubits[4]];
                (Controlled(SwapReverseRegister))([qubits[5]],qubitsToSwap);     
            


            // COde movement down
                X(qubits[5]); // Invert direction qubit for the ZeroControlled operations

                // Step 5
                set qubitsToSwap  = [qubits[3], qubits[4]];
                (Controlled(SwapReverseRegister))([qubits[5]],qubitsToSwap);     

                // Step 6
                set qubitsToSwap  = [qubits[2], qubits[3]];
                (Controlled(SwapReverseRegister))([qubits[5]],qubitsToSwap); 

                // Step 7
                set qubitsToSwap  = [qubits[1], qubits[2]];
                (Controlled(SwapReverseRegister))([qubits[5]],qubitsToSwap); 

                // Step 8
                set qubitsToSwap  = [qubits[0], qubits[1]];
                (Controlled(SwapReverseRegister))([qubits[5]],qubitsToSwap); 

                X(qubits[5]); // Back-invert for the direction qubit
        }  

        controlled auto;
    }  

    

    /// Make 6 movements. Every movement is controlled by the 6'th qubit.     
    /// After the every qubit we check if the fox has been captured and invert the 6'th qubit    
    /// Reminder: 6'th qubit equal to One means "Fox is free, go further"
    /// Circuit : https://algassert.com/quirk#circuit={%22cols%22:[[%22~27va%22,1,1,1,1,1,%22X%22],[%22~7vbh%22,1,1,1,1,1,%22%E2%80%A2%22],[%22~3miv%22,1,1,1,1,1,%22%E2%80%A2%22],[1,%22%E2%80%A2%22,1,1,1,1,%22X%22],[1,1,1,1,1,%22Swap%22,1,%22Swap%22],[%22~7vbh%22,1,1,1,1,1,%22%E2%80%A2%22],[%22~3miv%22,1,1,1,1,1,%22%E2%80%A2%22],[1,1,%22%E2%80%A2%22,1,1,1,%22X%22],[1,1,1,1,1,%22Swap%22,1,1,%22Swap%22],[%22~7vbh%22,1,1,1,1,1,%22%E2%80%A2%22],[%22~3miv%22,1,1,1,1,1,%22%E2%80%A2%22],[1,1,1,%22%E2%80%A2%22,1,1,%22X%22],[1,1,1,1,1,%22Swap%22,1,1,1,%22Swap%22],[%22~7vbh%22,1,1,1,1,1,%22%E2%80%A2%22],[%22~3miv%22,1,1,1,1,1,%22%E2%80%A2%22],[1,%22%E2%80%A2%22,1,1,1,1,%22X%22],[1,1,1,1,1,%22Swap%22,1,1,1,1,%22Swap%22],[%22~7vbh%22,1,1,1,1,1,%22%E2%80%A2%22],[%22~3miv%22,1,1,1,1,1,%22%E2%80%A2%22],[1,1,%22%E2%80%A2%22,1,1,1,%22X%22],[1,1,1,1,1,%22Swap%22,1,1,1,1,1,%22Swap%22],[%22~7vbh%22,1,1,1,1,1,%22%E2%80%A2%22],[%22~3miv%22,1,1,1,1,1,%22%E2%80%A2%22],[1,1,1,%22%E2%80%A2%22,1,1,%22X%22]],%22gates%22:[{%22id%22:%22~27va%22,%22name%22:%22Init%22,%22circuit%22:{%22cols%22:[[%22H%22,1,%22H%22],[%22%E2%80%A2%22,1,%22%E2%80%A2%22,%22X%22],[%22%E2%97%A6%22,%22X%22,%22%E2%97%A6%22],[%22X%22,1,%22X%22,%22%E2%80%A2%22],[1,1,1,%22%E2%80%A2%22,%22H%22],[1,1,1,%22X%22,%22%E2%80%A2%22]]}},{%22id%22:%22~7vbh%22,%22name%22:%22Set%20Current%20Move%22,%22circuit%22:{%22cols%22:[[1,1,1,1,%22%E2%80%A2%22,%22X%22],[1,1,1,%22%E2%80%A2%22,1,%22H%22],[1,1,%22%E2%80%A2%22,1,1,%22H%22],[1,%22%E2%80%A2%22,1,1,1,%22H%22]]}},{%22id%22:%22~3miv%22,%22name%22:%22Move%22,%22circuit%22:{%22cols%22:[[%22Swap%22,%22Swap%22,1,1,1,%22%E2%80%A2%22],[1,%22Swap%22,%22Swap%22,1,1,%22%E2%80%A2%22],[1,1,%22Swap%22,%22Swap%22,1,%22%E2%80%A2%22],[1,1,1,%22Swap%22,%22Swap%22,%22%E2%80%A2%22],[1,1,1,%22Swap%22,%22Swap%22,%22%E2%97%A6%22],[1,1,%22Swap%22,%22Swap%22,1,%22%E2%97%A6%22],[1,%22Swap%22,%22Swap%22,1,1,%22%E2%97%A6%22],[%22Swap%22,%22Swap%22,1,1,1,%22%E2%97%A6%22]]}}]}
    operation MakeSixMovements(qubits: Qubit[]) : Unit
    {
        body
        {
            // Move 1
            (Controlled(SetupMovementDirection))([qubits[6]],(qubits));
            (Controlled(MakeMovement))([qubits[6]],(qubits));                         
            CNOT(qubits[1], qubits[6]);      // Reverse Fox State if it's shot
            

            // Move 2  
            SwapReverseRegister([qubits[5], qubits[7]]); // Move the first move direction to the qubit 7, qubit 5 is Zero again
            (Controlled(SetupMovementDirection))([qubits[6]],(qubits));
            (Controlled(MakeMovement))([qubits[6]],(qubits));                         
            CNOT(qubits[2], qubits[6]);                  

            // Move 3  
            SwapReverseRegister([qubits[5], qubits[8]]);
            (Controlled(SetupMovementDirection))([qubits[6]],(qubits));
            (Controlled(MakeMovement))([qubits[6]],(qubits));                         
            CNOT(qubits[3], qubits[6]);                  

            // Move 4  
            SwapReverseRegister([qubits[5], qubits[9]]); 
            (Controlled(SetupMovementDirection))([qubits[6]],(qubits));
            (Controlled(MakeMovement))([qubits[6]],(qubits));                         
            CNOT(qubits[1], qubits[6]);                  

            // Move 5  
            SwapReverseRegister([qubits[5], qubits[10]]); 
            (Controlled(SetupMovementDirection))([qubits[6]],(qubits));
            (Controlled(MakeMovement))([qubits[6]],(qubits));                         
            CNOT(qubits[2], qubits[6]);      
            
            // Move 6  
            SwapReverseRegister([qubits[5], qubits[11]]); 
            (Controlled(SetupMovementDirection))([qubits[6]],(qubits));
            (Controlled(MakeMovement))([qubits[6]],(qubits));                         
            CNOT(qubits[3], qubits[6]);                                           
        }        
    }






    operation TestInit(): (Result, Result, Result, Result, Result)
    {
        body
        {
            mutable res0 = Zero;
            mutable res1 = Zero;
            mutable res2 = Zero;
            mutable res3 = Zero;
            mutable res4 = Zero;

            using(qubits=Qubit[16])
            {               
                // 0..4 - holes
                // 5 - current movement direction. Zero means "go down", One means "go up"
                // 6 - Game status. 1 means "fox is free, go further"
                // 7,8,9,10, 11 - movements history

                InitFoxHoles(qubits);     
                
                set res0 = M(qubits[0]);
                set res1 = M(qubits[1]);
                set res2 = M(qubits[2]);
                set res3 = M(qubits[3]);
                set res4 = M(qubits[4]);

                ResetAll(qubits); // ALWAYS clean after yourself        
            }    
            
            return (res0, res1, res2, res3, res4);        
        }         
    }



    operation TestMovementDirectionSetup(): (Result, Result, Result, Result, Result, Result)
    {
        body
        {
            mutable res0 = Zero;
            mutable res1 = Zero;
            mutable res2 = Zero;
            mutable res3 = Zero;
            mutable res4 = Zero;
            mutable res5 = Zero;

            using(qubits=Qubit[16])
            {   
                InitFoxHoles(qubits);     
                SetupMovementDirection(qubits);
                
                set res0 = M(qubits[0]);
                set res1 = M(qubits[1]);
                set res2 = M(qubits[2]);
                set res3 = M(qubits[3]);
                set res4 = M(qubits[4]);
                set res5 = M(qubits[5]);

                ResetAll(qubits); // ALWAYS clean after yourself        
            }    
            
            return (res0, res1, res2, res3, res4, res5);        
        }         
    }


    

    operation TestFirstMovement(): (Result, Result, Result, Result, Result, Result)
    {
        body
        {
            mutable res0 = Zero;
            mutable res1 = Zero;
            mutable res2 = Zero;
            mutable res3 = Zero;
            mutable res4 = Zero;
            mutable res5 = Zero;

            using(qubits=Qubit[16])
            {   
                InitFoxHoles(qubits);                     
                SetupMovementDirection(qubits);
                MakeMovement(qubits);
                
                set res0 = M(qubits[0]);
                set res1 = M(qubits[1]);
                set res2 = M(qubits[2]);
                set res3 = M(qubits[3]);
                set res4 = M(qubits[4]);
                set res5 = M(qubits[5]);

                ResetAll(qubits); // ALWAYS clean after yourself        
            }    
            
            return (res0, res1, res2, res3, res4, res5);        
        }         
    }

    operation TestSixMovements(): (Result)
    {
        body
        {
            mutable res = Zero;            

            using(qubits=Qubit[16])
            {   
                ResetAll(qubits);

                InitFoxHoles(qubits);     
                X(qubits[6]); // At the beginning of the game our fox is alive

                MakeSixMovements(qubits);

                set res = M(qubits[6]);
                ResetAll(qubits); // ALWAYS clean after yourself        
            }    
            
            return (res);              
        }
    }
}
