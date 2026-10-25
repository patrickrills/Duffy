import type { GoldieConfig } from "goldie";

/**
 * App Store screenshots and preview video for Duffy, rendered by goldie
 * (https://github.com/software-mansion-labs/goldie).
 *
 * The flows live in ../.argent/flows. Captures need Duffy's simulator demo
 * data, since a fresh simulator has no steps in Health. Turn it on once per
 * simulator (it survives the reinstall goldie does before every flow):
 *
 *   xcrun simctl spawn <udid> defaults write -g DuffyDemoHealthData -bool YES
 *
 * Build Release for the simulator first:
 *
 *   xcodebuild -project Duffy.xcodeproj -scheme Duffy -configuration Release \
 *     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
 */

const APP_ROOT = "/Users/patrickrills/Code/Duffy";

const config: GoldieConfig = {
  appRoot: APP_ROOT,
  appPath: `${process.env.HOME}/Library/Developer/Xcode/DerivedData/Duffy-ejlmvhqurzqnrebmetnfviqlqurq/Build/Products/Release-iphonesimulator/Duffy.app`,
  bundleId: "com.bigbluefly.Duffy",

  devices: ["iphone-6.9"],
  locales: ["en-US", "de-DE", "es-ES", "fr-FR", "ja-JP", "ko-KR", "uk-UA"],
  // Replay the flows once per language so the app on screen matches the copy
  localizedCaptures: true,
  appearance: "light",

  frame: { variant: "17-pro-silver" },

  theme: {
    // Duffy's sneaker blue, softened
    background: "linear-gradient(160deg, #DCE7FF 0%, #EEF3FF 55%, #FFFFFF 100%)",
    headlineColor: "#0A2A7A",
    subheadColor: "#4A5A7A",
    // The renderer can't resolve "-apple-system", so register SF Pro Display (installed in
    // /Library/Fonts) for Latin and Cyrillic, then fall back to Hiragino Sans for Japanese and
    // Apple SD Gothic Neo for Korean. The system stack drew Korean as tofu and dropped і/ї.
    fontFamily: '"SF Pro Display", "Hiragino Sans", "Apple SD Gothic Neo", sans-serif',
    fontFiles: [
      {
        family: "SF Pro Display",
        files: { 400: "/Library/Fonts/SF-Pro-Display-Regular.otf", 700: "/Library/Fonts/SF-Pro-Display-Bold.otf" },
      },
    ],
    copyHeightRatio: 0.24,
    deviceWidthRatio: 0.84,
    template: ["classic", "hero", "offset", "tilt-right"],
    layout: "classic",
  },

  store: {
    name: "Duffy",
    subtitle: {
      "en-US": "Simple step counter & trophies",
      "de-DE": "Einfacher Schrittzähler",
      "es-ES": "Contador de pasos sencillo",
      "fr-FR": "Podomètre simple et trophées",
      "ja-JP": "シンプルな歩数計",
      "ko-KR": "심플한 만보기와 트로피",
      "uk-UA": "Простий крокомір і нагороди",
    },
    developer: "Big Blue Fly",
    category: "Health & Fitness",
    // Cosmetic, studio only: placeholders, not Duffy's real rating
    rating: 4.8,
    ratingCount: "1.2K Ratings",
    ageRating: "4+",
    price: "Free",
    description: {
      "en-US":
        "Duffy is a simple, focused step counter. Open it to see today's steps, flights and distance, with an hour-by-hour chart of when you were on the move.\n\nLook back at any range in History to find your daily average, your best and worst days, and how often you hit your goal. Go past your goal to earn trophies, from the shoe all the way to the rocket at twice your goal.\n\nOn Apple Watch, Duffy puts your steps right on your watch face with complications that stay up to date through the day.",
      "de-DE":
        "Duffy ist ein einfacher, übersichtlicher Schrittzähler. Öffne die App und sieh deine Schritte, Etagen und Strecke von heute, dazu ein Diagramm, wann du Stunde für Stunde unterwegs warst.\n\nIm Verlauf siehst du für jeden Zeitraum deinen Tagesdurchschnitt, deine besten und schwächsten Tage und wie oft du dein Ziel erreicht hast. Übertriff dein Ziel und verdiene Trophäen, vom Schuh bis zur Rakete beim Doppelten deines Ziels.\n\nAuf der Apple Watch zeigt Duffy deine Schritte direkt auf dem Zifferblatt, mit Komplikationen, die den ganzen Tag aktuell bleiben.",
      "es-ES":
        "Duffy es un contador de pasos sencillo y centrado en lo esencial. Ábrelo para ver tus pasos, pisos y distancia de hoy, con un gráfico hora a hora de cuándo te has movido.\n\nEn el historial puedes consultar cualquier periodo para ver tu media diaria, tus mejores y peores días y cuántas veces has alcanzado tu objetivo. Supera tu objetivo para ganar trofeos, desde la zapatilla hasta el cohete al doblar tu objetivo.\n\nEn el Apple Watch, Duffy muestra tus pasos directamente en la esfera con complicaciones que se mantienen al día durante toda la jornada.",
      "fr-FR":
        "Duffy est un podomètre simple et épuré. Ouvrez-le pour voir vos pas, étages et distance du jour, avec un graphique heure par heure de vos moments actifs.\n\nDans l’historique, consultez n’importe quelle période pour connaître votre moyenne quotidienne, vos meilleurs et moins bons jours, et combien de fois vous avez atteint votre objectif. Dépassez votre objectif pour gagner des trophées, de la chaussure jusqu’à la fusée à deux fois votre objectif.\n\nSur l’Apple Watch, Duffy affiche vos pas directement sur le cadran grâce à des complications mises à jour tout au long de la journée.",
      "ja-JP":
        "Duffyはシンプルで使いやすい歩数計です。開くだけで、今日の歩数、上った階数、距離と、1時間ごとの活動グラフを確認できます。\n\n履歴では好きな期間の一日の平均、ベストな日とそうでない日、目標を達成した回数をふり返れます。目標を超えるとトロフィーを獲得。シューズから、目標の2倍で手に入るロケットまで揃っています。\n\nApple Watchでは、一日中更新されるコンプリケーションで歩数を文字盤に表示できます。",
      "ko-KR":
        "Duffy는 꼭 필요한 기능만 담은 심플한 만보기입니다. 앱을 열면 오늘의 걸음 수, 오른 층수, 이동 거리와 함께 시간대별 활동 그래프를 볼 수 있습니다.\n\n기록에서는 원하는 기간의 일일 평균, 가장 많이 걸은 날과 적게 걸은 날, 목표 달성 횟수를 확인할 수 있습니다. 목표를 넘으면 신발부터 목표의 두 배를 걸으면 받는 로켓까지 트로피를 모아 보세요.\n\nApple Watch에서는 하루 종일 업데이트되는 컴플리케이션으로 시계 화면에 걸음 수를 바로 표시합니다.",
      "uk-UA":
        "Duffy — простий і зручний крокомір. Відкрийте його, щоб побачити кроки, поверхи й відстань за сьогодні, а також погодинний графік вашої активності.\n\nВ історії переглядайте будь-який період: середнє за день, найкращі й найслабші дні та скільки разів ви досягли цілі. Перевершуйте ціль і отримуйте нагороди — від кросівка до ракети за подвійну ціль.\n\nНа Apple Watch Duffy показує кроки просто на циферблаті завдяки ускладненням, які оновлюються впродовж дня.",
    },
  },

  scenes: [
    {
      kind: "screenshot",
      id: "today",
      flow: "store-01-today",
      headline: {
        "en-US": "Elegant Step Counter",
        "de-DE": "Eleganter Schrittzähler",
        "es-ES": "Contador de pasos elegante",
        "fr-FR": "Un podomètre élégant",
        "ja-JP": "エレガントな\n歩数計",
        "ko-KR": "세련된 만보기",
        "uk-UA": "Елегантний крокомір",
      },
    },
    {
      kind: "screenshot",
      id: "history",
      flow: "store-02-history",
      headline: {
        "en-US": "Trends for Steps & More",
        "de-DE": "Trends für Schritte & mehr",
        "es-ES": "Tendencias de pasos y más",
        "fr-FR": "Tendances de vos pas et plus",
        "ja-JP": "歩数などの\n傾向をチェック",
        "ko-KR": "걸음 수 등 다양한 추세",
        "uk-UA": "Тренди кроків і не тільки",
      },
    },
    {
      kind: "screenshot",
      id: "week",
      flow: "store-03-week",
      headline: {
        "en-US": "Easy Access to Step History",
        "de-DE": "Schrittverlauf mit einem Tipp",
        "es-ES": "Historial de pasos al instante",
        "fr-FR": "Historique de pas en un geste",
        "ja-JP": "歩数の履歴に\nすぐアクセス",
        "ko-KR": "걸음 기록을 간편하게",
        "uk-UA": "Історія кроків під рукою",
      },
    },
    {
      kind: "screenshot",
      id: "trophies",
      flow: "store-04-trophies",
      headline: {
        "en-US": "Celebrate Your Progress",
        "de-DE": "Feiere deine Fortschritte",
        "es-ES": "Celebra tu progreso",
        "fr-FR": "Célébrez vos progrès",
        "ja-JP": "成果を\nお祝いしよう",
        "ko-KR": "나의 성과를 축하하세요",
        "uk-UA": "Святкуйте свої успіхи",
      },
    },
    {
      kind: "preview",
      id: "preview",
      segments: [
        { id: "today", flow: "store-preview-01-today" },
        { id: "history", flow: "store-preview-02-history" },
        { id: "trophies", flow: "store-preview-03-trophies", holdSeconds: 1 },
      ],
    },
  ],
};

export default config;
