# TP_FLUTTER
TP flutter rendu par 24064,24052,24078
CONCLUSION:
Ce TP a permis de développer une application de bloc-notes complète en Flutter en introduisant progressivement une architecture plus structurée et évolutive. Au départ, la gestion des données était réalisée localement dans les widgets à l’aide de setState, ce qui entraînait une forte dépendance entre l’interface utilisateur et la logique métier.

L’introduction du pattern Provider via ChangeNotifier a constitué une amélioration majeure. Elle a permis de centraliser la gestion des notes dans un service dédié (NoteService), séparant ainsi clairement la logique métier de la couche UI. Grâce à notifyListeners(), l’application devient réactive : toute modification des données (ajout, suppression ou mise à jour d’une note) est automatiquement reflétée dans l’interface utilisateur sans avoir recours à des mises à jour manuelles avec setState.

L’utilisation de context.watch, context.read et Consumer a également permis d’optimiser la gestion des reconstructions des widgets, en rendant l’interface plus performante et mieux structurée. Par ailleurs, les fonctionnalités ajoutées telles que la recherche en temps réel, le tri des notes et l’affichage dynamique du compteur ont renforcé l’aspect fonctionnel et interactif de l’application.

Enfin, ce TP met en évidence l’importance d’une bonne architecture dans le développement Flutter. L’approche basée sur Provider améliore la maintenabilité, la lisibilité du code et la scalabilité de l’application, tout en facilitant l’ajout de nouvelles fonctionnalités.
