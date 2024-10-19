// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract UserManager {
    struct User {
        address userAddress;
        bool isActive;
    }

    mapping(address => User) public users; // Mapping per memorizzare gli utenti
    address[] public userAddresses; // Array per tenere traccia degli indirizzi degli utenti

    // Funzione per aggiungere un nuovo utente
    function addUser(address userAddress, bool isActive) public {
        users[userAddress] = User(userAddress, isActive);
        userAddresses.push(userAddress);
    }

    // Funzione per eliminare gli utenti inattivi dall'array
    function removeInactiveUsers() public {
        uint256 activeCount = 0;

        for (uint i = 0; i < userAddresses.length; i++) {
            if (users[userAddresses[i]].isActive) {
                // Se l'utente è attivo, manteniamo l'indirizzo
                userAddresses[activeCount] = userAddresses[i];
                activeCount++;
            }
        }

        // Ridimensioniamo l'array per contenere solo gli indirizzi attivi
        assembly {
            mstore(userAddresses, activeCount) // Aggiorna la lunghezza dell'array
        }
    }

    // Funzione per ottenere tutti gli utenti attivi
    function getActiveUsers() public view returns (address[] memory) {
        return userAddresses; // Ritorna l'array attuale, che può essere ridimensionato
    }

    // Funzione per aggiornare lo stato di attivazione di un utente
    function updateUserStatus(address userAddress, bool isActive) public {
        users[userAddress].isActive = isActive;
    }
}


uint256[] public pendingLoansByAmount; // Array per memorizzare gli importi dei prestiti in attesa

    // Funzione per inserire un valore mantenendo l'ordine decrescente
    function insertLoanAmount(uint256 _amount) public {
        // Iniziamo a cercare la posizione per l'inserimento
        uint256 i = 0;
        
        // Troviamo la posizione corretta per il nuovo importo
        while (i < pendingLoansByAmount.length && pendingLoansByAmount[i] >= _amount) {
            i++;
        }

        // Inseriamo il nuovo importo nella posizione trovata
        pendingLoansByAmount.push(_amount); // Aggiungiamo un valore "dummy" alla fine
        for (uint256 j = pendingLoansByAmount.length - 1; j > i; j--) {
            pendingLoansByAmount[j] = pendingLoansByAmount[j - 1]; // Sposta gli elementi verso destra
        }
        pendingLoansByAmount[i] = _amount; // Inserisce il nuovo importo nella posizione corretta
    }