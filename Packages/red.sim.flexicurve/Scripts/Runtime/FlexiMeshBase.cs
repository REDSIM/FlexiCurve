using UnityEngine;

namespace Flexicurve {
    public abstract class FlexiMeshBase {

        public BezierCurve Curve;

        public Vector3[] Vertices { get; protected set; }
        public Vector3[] Normals { get; protected set; }
        public int[] Triangles { get; protected set; }
        public Vector4[] UV0 { get; protected set; }
        public Vector2[] UV1 { get; protected set; }

        public float Length => _length;
        protected float _length = 0; // Physical length

        public virtual void Recalculate(int offset) { }

        public void Recalculate() {
            Recalculate(0);
        }

    }
}