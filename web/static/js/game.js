// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import { Socket } from "phoenix"

const $status = document.getElementById("status")
const $board = document.getElementById("board")
const $turn = document.getElementById("turn")

let playingAs

const icons = {
  null: "",
  0: "X",
  1: "0"
}

function gridButton(value, index) {
  return `<button class="btn btn-default grid-item play-move" data-index="${index}">${value}</button>`
}

function transformBoard(board) {
  let i = 0;
  let newBoard = []
  let rowSize = Math.sqrt(board.length)
  for (i; i < board.length; i += rowSize) {
    let row = board.slice(i , i + rowSize).map((marker, index) => icons[marker])
    newBoard.push(row)
  }
  return newBoard
}

function renderBoard(board, render) {
  board = transformBoard(board)
  let html = ""
  let i
  let j
  for (i = 0; i < board.length; i++) {
    for (j = 0; j < board[i].length; j++) {
      html += render(board[i][j], (i * board[i].length) + j)
    }
    html += "<br />"
  }
  $board.innerHTML = html
}

function updateGame(data) {
  renderBoard(data.board, gridButton);
  $turn.innerHTML = `Current turn ${data.x_turn ? "X" : "O"}`
}

function finishGame(data) {
  renderBoard(data.board, (value, index) => {
    let className = "btn btn-default grid-item";
    if (data.win_line.indexOf(index) !== -1) {
      className += " winline"
    }
    return `<button class="${className}" data-index="${index}">${value}</button>`
  });

  let result;
  if ((data.winner !== null) && data.players[data.winner] === window.userId) {
    result = "You won!"
  } else {
    result = (data.winner === false) ? "draw" : "You lost!"
  }
  $turn.innerHTML = result
}

function setGameState(data) {
  if (data.players) {
    playingAs = (data.players[0] === window.userId) ? "X" : "O"
    $status.innerHTML = `Playing as ${playingAs}`
  }

  if (data.status === "waiting") {
    $status.innerHTML = "Waiting for players"
  } else if (data.status === "started") {
    updateGame(data);
  } else if (data.status === "finished") {
    finishGame(data)
  }
}

function handleConnectError(data) {
  status.innerHTML = `Could not connect: ${data.error}`
}

if (window.gameId) {
  const socket = new Socket("/socket", { params: { token: window.userToken } })

  socket.connect()

  // Now that you are connected, you can join channels with a topic:
  const channel = socket.channel(`games:${window.gameId}`, {})
  channel.join()
    .receive("ok", setGameState)
    .receive("error", handleConnectError)

  channel.on("game:start", setGameState)
  channel.on("game:update", updateGame)
  channel.on("game:over", finishGame)

  document.addEventListener("click", (e) => {
    const target = e.target;
    if (target.className.indexOf("play-move") !== -1) {
      channel.push("game:move", {index: target.dataset.index})
      .receive("ok", setGameState)
    }
  });
}
