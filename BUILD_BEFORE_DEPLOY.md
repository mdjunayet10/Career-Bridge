# Build before Firebase deploy

The source files in this package contain the latest changes. The `backend/firebase/public/` folder is generated output from an earlier build and is kept only because this is a full project copy.

**Do not deploy that folder directly without rebuilding.** Use:

```bash
./scripts/deploy_firebase.sh
```

The script rebuilds Flutter web from the current source, replaces `backend/firebase/public/`, and then deploys Firestore rules/indexes + Hosting.
