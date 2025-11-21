using System.Collections.Generic;
using UnityEngine;

namespace Flexicurve {

    public class BezierTinselMesh : FlexiMeshBase {

        public float Spacing = 0.1f;
        public float Radius = 0.05f;
        public int Edges = 5;
        public float Decimation = 1;

        public BezierTinselMesh() { }

        public BezierTinselMesh(BezierCurve curve, float radius, float spacing, int edges, float decimation) {
            Curve = curve;
            Radius = radius;
            Edges = edges;
            Spacing = spacing;
            Decimation = decimation;
        }

        public BezierTinselMesh(Vector3 a, Vector3 b, float sag, float radius, float spacing, int edges, float decimation) {
            Curve = Utils.BezierWire(a, b, sag);
            Radius = radius;
            Edges = edges;
            Spacing = spacing;
            Decimation = decimation;
        }

        // Recalculates points, vertices, triangles. Offset of vertex indexes for triangles array. Usefull when manually batching meshes.
        public override void Recalculate(int offset) {

            _length = 0; // Resetting physical length

            Vector3 tangent; // Calculating tangent for circle formation
            Vector3 dir = Curve.P0 - Curve.P3;
            // If this segment is vertical, there is another way to calculate tangent
            if (Mathf.Abs(dir.x) < 0.00001f && Mathf.Abs(dir.z) < 0.00001f) tangent = Vector3.Cross(Vector3.forward, dir).normalized;
            else tangent = Vector3.Cross(Vector3.up, dir).normalized;

            Vector3[] pointsRaw = Curve.GetUniformPointArray(Spacing); // Raw not decimated points array
            List<Vector3> points = new List<Vector3>(); // Decimated points array

            // Mesh attributes
            List<Vector3> vertices = new List<Vector3>();
            List<Vector3> normals = new List<Vector3>();
            List<int> triangles = new List<int>();
            List<Vector4> uv0 = new List<Vector4>();
            List<Vector2> uv1 = new List<Vector2>();

            Vector3 dirCurr; // Current direction to compare
            Vector3 dirPrev; // Prev direction to compare
            Vector3 pointLast = pointsRaw[0]; // Last point added to points array

            // Decimating curve by filtering points we dont need and calculating overall physical length
            for (int i = 0; i < pointsRaw.Length; i++) {
                if (i > 0 && i < pointsRaw.Length - 1 && Decimation > 0) {
                    // Skip point if there's no big difference in angle between current and previous directions
                    dirCurr = pointsRaw[i + 1] - pointsRaw[i];
                    dirPrev = pointsRaw[i] - pointLast;
                    float dot = Vector3.Dot(dirCurr.normalized, dirPrev.normalized);
                    if (dot * dot > 1 - Decimation) continue;
                }

                if (i != 0) _length += (pointsRaw[i] - pointLast).magnitude; // Incrementing length
                pointLast = pointsRaw[i];
                points.Add(pointLast);
            }

            // Iterating through points
            float currentLength = 0;
            int pointsCount = points.Count;
            for (int i = 0; i < pointsCount; i++) {

                // Calculating normal for circle generation
                if (i == 0) dirCurr = Vector3.Normalize(points[i + 1] - points[i]); // First point
                else if (i == pointsCount - 1) dirCurr = Vector3.Normalize(points[i] - points[i - 1]); // Last point
                else dirCurr = Vector3.Normalize(Vector3.Normalize(points[i + 1] - points[i]) + Vector3.Normalize(points[i] - points[i - 1])); // Other points

                int vtc = vertices.Count; // Current vertex count in previous loops

                // Calculating X-UV
                float x0 = 0, x1 = 0; // x0 is X for main uv map, x1 is X for lightmap uv
                if (i != 0) {
                    currentLength += (points[i] - points[i - 1]).magnitude;
                    x0 = currentLength / (Mathf.PI * 2 * Radius);
                    x1 = Mathf.Clamp01(currentLength / _length);
                }

                int sides = Edges / 2;
                for (int n = 0; n < sides; n++) {
                    // Iterating through vertex loop

                    // Generating vertices
                    float angle = Mathf.PI * n / sides + Mathf.PI / 2;
                    Vector3 vert = Utils.PointOnCircle(points[i], Radius, dirCurr, tangent, angle); // First vertex
                    Vector3 vert2 = Utils.PointOnCircle(points[i], Radius, dirCurr, tangent, angle + Mathf.PI); // Second vertex on oposite side
                    vertices.Add(vert);
                    vertices.Add(vert2);

                    // Generating normals
                    Vector3 normal = Vector3.Normalize(Vector3.Cross(vert2 - vert, dirCurr));
                    normals.Add(normal);
                    normals.Add(normal);

                    // Calculating Y-UV
                    float x = x0 + (float)1 / (n + 1);
                    uv0.Add(new Vector4(x, 0, 0, 0));
                    uv0.Add(new Vector4(x, 1, 0, 0));
                    uv1.Add(new Vector2(x1, 0));
                    uv1.Add(new Vector2(x1, 1));

                    // Generating quads
                    if (i == pointsCount - 1) continue; // Skip last loop

                    int n2 = n * 2;
                    int nn = n2 + 1;

                    // First triangle
                    triangles.Add(offset + vtc + n2);
                    triangles.Add(offset + vtc + nn);
                    triangles.Add(offset + vtc + n2 + sides * 2);
                    // Second triangle
                    triangles.Add(offset + vtc + nn);
                    triangles.Add(offset + vtc + nn + sides * 2);
                    triangles.Add(offset + vtc + n2 + sides * 2);

                }

            }

            Vertices = vertices.ToArray();
            Normals = normals.ToArray();
            Triangles = triangles.ToArray();
            UV0 = uv0.ToArray();
            UV1 = uv1.ToArray();

        }

    }
}