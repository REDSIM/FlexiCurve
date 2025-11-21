using UnityEngine;

namespace Flexicurve {

    [CreateAssetMenu(fileName = "FlexiCurve", menuName = "FlexiCurve", order = 1000)]
    public class FlexiCurvePreset : ScriptableObject {

        [Header("Visuals")] public Material Material = null;

        [Header("Curve Mesh")]

        [SerializeField] public FlexiCurve.WireType Type = FlexiCurve.WireType.Wire;
        [SerializeField] public bool GenerateWires = true;

        [SerializeField][Min(0.05f)] public float Spacing = 0.1f;
        [SerializeField][Range(0, 1)] public float Decimatation = 0.15f;
        [SerializeField][Min(0.001f)] public float Radius = 0.01f;
        [SerializeField][Min(3)] public int Edges = 3;

        [Header("Elements Scattering")]
        [SerializeField] public Mesh Element;

        [SerializeField] public float ElementsScale = 1f;
        [SerializeField][Min(0.05f)] public float ElementsSpacing = 0.2f;
        [SerializeField][Range(0, 1f)] public float DirectionRandomization = 0.3f;
        [SerializeField] public bool RandomizeRotation = true;
        [SerializeField] public bool GeneratePerElementWires = true;
        [SerializeField] public float ElementOffset = 0.1f;

        public FlexiCurvePreset(FlexiCurve flexicurve) {

            if(flexicurve.TryGetComponent(out Renderer renderer)) Material = renderer.sharedMaterial;

            Type = flexicurve.Type;
            GenerateWires = flexicurve.GenerateWires;
            Spacing = flexicurve.Spacing;
            Decimatation = flexicurve.Decimatation;
            Radius = flexicurve.Radius;
            Edges = flexicurve.Edges;

            Element = flexicurve.Element;
            ElementsScale = flexicurve.ElementsScale;
            ElementsSpacing = flexicurve.ElementsSpacing;
            DirectionRandomization = flexicurve.DirectionRandomization;
            RandomizeRotation = flexicurve.RandomizeRotation;
            GeneratePerElementWires = flexicurve.GenerateWires;
            ElementOffset = flexicurve.ElementOffset;

        }

        private void OnValidate() {
            if (Spacing < 0.05f) Spacing = 0.05f;
            if (ElementsSpacing < 0.05f) ElementsSpacing = 0.05f;
            if (Edges < 3) Edges = 3;
            if (Radius < 0.001f) Radius = 0.001f;
        }

    }

}