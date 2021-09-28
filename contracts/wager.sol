// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;


contract GameWager {

    enum State { Created, Accepted, Finished }
    
    struct Wager {
        uint id;
        address owner;
        uint ownerWagerAmount;
        address player2;
        uint player2WagerAmount;
        State state;
    }

    mapping (uint => Wager) wagers;
    mapping (uint => bool) wagerIDs;

    event WagerCreated(Wager wager);
    event WagerAccepted(Wager wager);
    event WagerFinished(Wager wager);

    function createWager(uint wagerID) external payable {
        require(wagerIDs[wagerID] == false);

        Wager memory wager = Wager ({
            id: wagerID,
            owner: msg.sender,
            ownerWagerAmount: msg.value,
            player2: address(0x0),
            player2WagerAmount: 0,
            state: State.Created
        });

        wagers[wagerID] = wager;
        wagerIDs[wagerID] = true;
        emit WagerCreated(wager);
    }

    function AcceptWager(uint wagerID) external payable {
        require(wagerIDs[wagerID] == true);
        Wager memory wager = wagers[wagerID];

        require(wager.state == State.Created && wager.ownerWagerAmount == msg.value);

        wager.player2 = msg.sender;
        wager.player2WagerAmount = msg.value;
        wager.state = State.Accepted;
        wagers[wagerID] = wager;

        emit WagerAccepted(wager);
    }

    function PayoutWager(uint wagerID, address winner) external {
        require(wagerIDs[wagerID] == true);
        Wager memory wager = wagers[wagerID];

        require(wager.state == State.Accepted);
        require(winner == wager.owner || winner == wager.player2);

        payable(winner).transfer(wager.ownerWagerAmount * 2);

        wager.state = State.Finished;
        wagerIDs[wagerID] = false;

        emit WagerFinished(wager);
    }

}