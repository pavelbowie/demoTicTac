import Kitura
import LoggerAPI
import HeliumLogger
import KituraStencil

HeliumLogger.use(.entry)
let router = Router()
let leaderboardRouter = LeaderboardRouter()

// curl --header "Content-Type: application/json" --request POST -d '{"name": "RED", "moves":5,"time": 0.6193609237670898}'  http://127.0.0.1:8090/leaderboard
    .json

router.setDefault(templateEngine: StencilTemplateEngine())
router.all("/leaderboard.json", middleware: BodyParser())
router.post("/leaderboard.json", handler:leaderboardRouter.postScore)
router.get("/leaderboard.json", handler:leaderboardRouter.getJSONScores)
router.get("/leaderboard.html", handler:leaderboardRouter.getHTMLScores)

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
