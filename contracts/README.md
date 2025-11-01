# Contracts Reference — celo_p2e

Tài liệu ngắn gọn cho từng contract trong thư mục contracts. Dành cho: frontend dev, backend scripts, devops/deployer, và reviewer/auditor.

---

## GameOwner.sol
Dành cho: owner (deployer / admin), backend deploy scripts, auditors.

Mục đích cụ thể:
- Quản lý cấu hình game (stakeAmount, rewardAmount, targetScore).
- Chỉ owner được thay đổi cấu hình và nạp tiền trả thưởng.
- Lưu reward pending cho người chơi thắng và cho phép họ rút.

Key state:
- owner — admin address
- stakeAmount, rewardAmount, targetScore — cấu hình game
- playerGame — address của PlayerGame (chỉ hợp lệ contract được ủy quyền)
- rewards mapping(address => uint256)

Hàm quan trọng:
- constructor(stake, reward, target)
- setPlayerGame(address) — onlyOwner: ủy quyền PlayerGame gọi recordWin
- recordWin(address player) — onlyPlayerGame: thêm reward cho player
- claimReward() payable -> rút reward (player gọi)
- fundGame() payable — owner nạp tiền vào contract
- updateGameConfig(...) — chỉ owner

Sự kiện:
- RewardAdded(address player, uint256 amount)
- RewardClaimed(address player, uint256 amount)
- GameFunded(address from, uint256 amount)
- ConfigUpdated(...)

Lưu ý bảo mật:
- Kiểm tra balance trước khi thêm reward.
- Reentrancy: claimReward nên set balance trước khi transfer (đã kiểm tra).
- Chỉ setPlayerGame khi deploy sẵn PlayerGame.

Ví dụ gọi:
- Owner deploy -> gọi setPlayerGame(playerGameAddress) -> gọi fundGame({value: ...})

---

## PlayerGame.sol
Dành cho: người chơi (frontend), backend game logic, deployer (khi nối hợp đồng).

Mục đích cụ thể:
- Cho phép người chơi stake (payable startGame) và submit score (finishGame).
- Nếu đạt target, gọi GameOwner.recordWin để cấp reward.
- Tùy chọn thông báo OwnerPlayer để lưu lịch sử.

Key state:
- gameOwner (GameOwner contract)
- ownerPlayer (OwnerPlayer contract) — optional
- playerScores, hasStaked

Hàm quan trọng:
- constructor(address _gameOwnerAddress, address _ownerPlayerAddress)
- startGame() payable — người chơi gửi đúng stakeAmount
- finishGame(uint256 _score) — lưu điểm, nếu thắng gọi gameOwner.recordWin, thông báo ownerPlayer nếu có
- receive() external payable — nhận ETH từ GameOwner khi trả thưởng (nếu cần)

Sự kiện:
- PlayerStaked(address, amount)
- PlayerScored(address, score)
- PlayerWon(address, reward)

Ai gọi gì:
- Người chơi wallet: startGame() (payable), finishGame(score)
- Contract GameOwner: được gọi nội bộ từ PlayerGame khi player thắng
- Owner (deployer): chỉ cần deploy, có thể truyền ownerPlayer address hoặc set sau (OwnerPlayer.setPlayerGame)

Lưu ý triển khai:
- Khi deploy truyền gameOwner address; ownerPlayer có thể truyền address(0) rồi set sau.
- Đảm bảo GameOwner.setPlayerGame trỏ tới địa chỉ PlayerGame để recordWin chấp nhận call.
- Xác thực msg.sender trong start/finish bằng hasStaked mapping.

---

## OwnerPlayer.sol
Dành cho: analytics/back-end, owner admin, frontend (nếu hiển thị lịch sử).

Mục đích cụ thể:
- Ghi lại tương tác chơi (log/history) để phục vụ analytics hoặc hiển thị lịch sử.
- Có thể được deploy trước hoặc sau PlayerGame; cần setPlayerGame để nối.

Key state:
- gameOwner (GameOwner contract) — để biết owner (tuỳ impl)
- playerGame — authorized PlayerGame address
- interactions mapping / events

Hàm quan trọng:
- constructor(address _gameOwner, address _playerGame)
- setPlayerGame(address) — onlyOwner (owner của GameOwner) để set playerGame nếu deploy trước
- recordInteraction(address player, uint256 score, bool won) — chỉ playerGame có thể gọi

Sự kiện:
- GamePlayed(address player, uint256 score, bool won, uint256 timestamp)

Ai gọi gì:
- PlayerGame contract: gọi recordInteraction(...) khi finishGame
- Owner (admin): setPlayerGame(playerGameAddress)
- Frontend/backend: đọc events để hiển thị lịch sử

Lưu ý:
- Nếu deploy OwnerPlayer trước PlayerGame, khởi tạo playerGame = address(0) và gọi setPlayerGame sau từ account owner.
- Không lưu private data trên-chain; chỉ lưu minimal event/data cho analytics.

---

## Quy trình deploy & nối (tóm tắt)
1. Deploy GameOwner với (stake, reward, target) — deployer sẽ là owner.
2. Deploy OwnerPlayer(gameOwnerAddress, address(0)).
3. Deploy PlayerGame(gameOwnerAddress, ownerPlayerAddress).
4. Từ account owner (deployer):
   - OwnerPlayer.setPlayerGame(playerGame.address)
   - GameOwner.setPlayerGame(playerGame.address)
5. Owner gọi GameOwner.fundGame() gửi đủ tiền trả reward.
6. Người chơi: startGame() (payable) -> finishGame(score) -> nếu thắng claimReward từ GameOwner.

---

## Gợi ý cho frontend / backend
- Lưu ABI + addresses của 3 contract.
- Lắng nghe events: PlayerStaked/PlayerScored/PlayerWon, RewardAdded/RewardClaimed, GamePlayed.
- Kiểm tra stakeAmount qua gameOwner.stakeAmount() trước khi gọi startGame.
- Chỉ show admin buttons nếu wallet === gameOwner.owner().

---

Cần cập nhật README chính (root) để chèn link tới file này? Có thể tạo script deploy tự động in addresses vào `deployed.json`.