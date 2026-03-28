import { createBrowserRouter } from "react-router";
import Root from "./components/Root";
import DictionaryManagement from "./components/DictionaryManagement";
import SynonymManagement from "./components/SynonymManagement";
import ProverbManagement from "./components/ProverbManagement";
import Dashboard from "./components/Dashboard";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Root,
    children: [
      { index: true, Component: Dashboard },
      { path: "dictionary", Component: DictionaryManagement },
      { path: "synonyms", Component: SynonymManagement },
      { path: "proverbs", Component: ProverbManagement },
    ],
  },
]);
