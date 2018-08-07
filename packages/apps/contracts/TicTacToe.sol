pragma solidity 0.4.24;
pragma experimental "ABIEncoderV2";

import "@counterfactual/contracts/contracts/lib/Transfer.sol";


contract TicTacToe {

  enum ActionType {
    PLAY,
    PLAY_AND_WIN,
    PLAY_AND_DRAW,
    DRAW
  }

  enum WinClaimType {
    COL
    ROW,
    DIAG,
    CROSS_DIAG
  }

  struct WinClaim {
    WinClaimType winClaimType;
    uint256 winClaimIdx;
  }

  struct AppState {
    address[2] players;
    uint256 turnNum;
    uint256 winner; // 0 => game in progress, 3 => draw, i => player[i-1] won otherwise
    uint256[3][3] board; // 0 => empty square, i => players[i-1] otherwise
  }

  struct Action {
    ActionType actionType;
    uint256 playX;
    uint256 playY;
    WinClaim winClaim;
  }

  AppState public appState;

  function turn(AppState state)
    public
    pure
    returns (uint256)
  {
    return state.turnNum % 2;
  }

  function reduce(AppState state, Action action)
    public
    view
    returns (bytes)
  {
    AppState memory postState;
    if (action.actionType == actionType.PLAY) {
      postState = playMove(postState, state.turnNum % 2, action.playX, action.playY);
    } else if (action.actionType == actionType.PLAY_AND_DRAW) {
      postState = playMove(postState, state.turnNum % 2, action.playX, action.playY);
      assertBoardIsFull(postState);
      postState.winner = 3;
    } else if (action.actionType == actionType.PLAY_AND_WIN) {
      postState = playMove(postState, state.turnNum % 2, action.playX, action.playY);
      assertWin(state.turnNum % 2, postState, action.winClaim);
      postState.winner = playerId + 1;
    } else if (action.actionType == actionType.DRAW) {
      assertBoardIsFull(postState);
      postState.winner = 3;
    }

    postState.turnNum += 1;

    return abi.encode(postState);
  }

  function playMove(AppState preState, uint256 playerId, uint256 x, uint256 y) returns AppState {
    require(preState.board[x][y] == 0);
    require(playerId == 0 || playerId == 1);

    AppState memory postState;
    postState.board[x][y] = playerId + 1;

    return postState;
  }

  function assertBoardIsFull(AppState appState) {
    for (uint256 i=0; i<3; i++) {
      for (uint256 j=0; j<3; j++) {
        require(appState.board[i][j] != 0);
      }
    }
  }

  function assertWin(uint256 playerId, AppState postState, WinClaim winClaim) {
    if (winClaim.winClaimType == WinClaimType.COL) {
      require(appState.board[winClaim.winClaimIdx][0] == playerId + 1);
      require(appState.board[winClaim.winClaimIdx][1] == playerId + 1);
      require(appState.board[winClaim.winClaimIdx][2] == playerId + 1);
    } else if (winClaim.winClaimType == WinClaimType.ROW) {
      require(appState.board[0][winClaim.winClaimIdx] == playerId + 1);
      require(appState.board[1][winClaim.winClaimIdx] == playerId + 1);
      require(appState.board[2][winClaim.winClaimIdx] == playerId + 1);
    } else if (winClaim.winClaimType == WinClaimType.DIAG) {
      require(appState.board[0][0] == playerId + 1);
      require(appState.board[1][1] == playerId + 1);
      require(appState.board[2][2] == playerId + 1);
    } else if (winClaim.winClaimType == WinClaimType.CROSS_DIAG) {
      require(appState.board[2][0] == playerId + 1);
      require(appState.board[1][1] == playerId + 1);
      require(appState.board[0][2] == playerId + 1);
    }

  }

}
