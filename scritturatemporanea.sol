// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Prestito {
    // Variabili per le variazioni del tasso d'interesse in base al credit score
    uint256 public aumentoCreditScore0 = 150; // 50% di aumento
    uint256 public tassoInvariato = 100;       // Nessuna variazione
    uint256 public diminuzioneCreditScore2 = 90; // 10% di diminuzione
    uint256 public diminuzioneCreditScore3 = 70; // 30% di diminuzione
    uint256 public diminuzioneCreditScore4 = 50; // 50% di diminuzione

    // Funzione per calcolare gli interessi di un prestito
    function calcolaInteressi(
        uint256 importo,       // Importo del prestito
        uint256 tassoBase,     // Tasso d'interesse annuale di base
        uint256 giorni,        // Giorni di prestito
        uint8 creditScore      // Credit score (0-4)
    ) public view returns (uint256) {
        uint256 tassoInteresse;

        // Determinazione del tasso d'interesse in base al credit score
        if (creditScore == 0) {
            tassoInteresse = (tassoBase * aumentoCreditScore0) / 100; // Aumento del 50%
        } else if (creditScore == 1) {
            tassoInteresse = (tassoBase * tassoInvariato) / 100; // Tasso invariato
        } else if (creditScore == 2) {
            tassoInteresse = (tassoBase * diminuzioneCreditScore2) / 100; // Diminuzione del 10%
        } else if (creditScore == 3) {
            tassoInteresse = (tassoBase * diminuzioneCreditScore3) / 100; // Diminuzione del 30%
        } else if (creditScore == 4) {
            tassoInteresse = (tassoBase * diminuzioneCreditScore4) / 100; // Diminuzione del 50%
        } else {
            revert("Credit score deve essere tra 0 e 4");
        }

        // Calcolo degli interessi
        uint256 interessi = (importo * tassoInteresse * giorni) / (365 * 100); // Diviso per 100 per il tasso in percentuale

        return interessi;
    }

    // Funzioni per modificare le variazioni del tasso d'interesse (opzionali)
    function setAumentoCreditScore0(uint256 nuovoValore) public {
        aumentoCreditScore0 = nuovoValore;
    }

    function setDiminuzioneCreditScore2(uint256 nuovoValore) public {
        diminuzioneCreditScore2 = nuovoValore;
    }

    function setDiminuzioneCreditScore3(uint256 nuovoValore) public {
        diminuzioneCreditScore3 = nuovoValore;
    }

    function setDiminuzioneCreditScore4(uint256 nuovoValore) public {
        diminuzioneCreditScore4 = nuovoValore;
    }

    function setTassoInvariato(uint256 nuovoValore) public {
        tassoInvariato = nuovoValore;
    }
}
