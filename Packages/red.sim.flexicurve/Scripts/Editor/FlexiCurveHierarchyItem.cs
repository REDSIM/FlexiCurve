using UnityEditor;
using UnityEngine;

namespace Flexicurve {
    public static class HierarchyMenu {

        [MenuItem("GameObject/FlexiCurve Mesh", false, 9999)]
        private static void CreateFlexiCurve(MenuCommand cmd) {

            var go = new GameObject(GetUniqueName("FlexiCurve Mesh"));

            FlexiCurve curve = go.AddComponent<FlexiCurve>();

            GameObjectUtility.SetParentAndAlign(go, cmd.context as GameObject);

            curve.Reset();

            Undo.RegisterCreatedObjectUndo(go, $"Create new FlexiCurve Mesh");

            Selection.activeObject = go;

        }

        private static string GetUniqueName(string baseName) {
            if (GameObject.Find(baseName) == null)
                return baseName;

            int idx = 1;
            string candidate;
            do {
                candidate = $"{baseName} ({idx++})";
            } while (GameObject.Find(candidate) != null);

            return candidate;
        }

    }
}