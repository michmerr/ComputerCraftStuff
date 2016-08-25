using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AspectMapper
{
    public class AspectNodeSet : KeyedCollection<string, AspectNode>
    {
        public static AspectNodeSet Load(string filename)
        {
            string[] data = File.ReadAllLines(filename);

            AspectNodeSet result = new AspectNodeSet();
            foreach (string line in data)
            {
                string[] tokens = line.Split(new[] {','}, StringSplitOptions.RemoveEmptyEntries);
                string name = tokens[0].Trim();
                if (tokens.Length < 2)
                {
                    result.Add(new AspectNode(name));
                    continue;
                }

                result.Add(new AspectNode(name, tokens.Skip(1).Select(p => result[p.Trim()])));
            }

            return result;
        }

        public AspectNodeSet()
        {

        }

        public AspectNodeSet(IEnumerable<AspectNode> nodes)
        {
            foreach (AspectNode node in nodes)
            {
                this.Add(node);
            }
        }

        protected override string GetKeyForItem(AspectNode item)
        {
            return item.Name;
        }

        public Dictionary<string, Dictionary<string, List<AspectNode[]>>> GetCommonNodes(params Tuple<string, int>[] aspectOrders)
        {
            var result = new Dictionary<string, Dictionary<string, List<AspectNode[]>>>();

            // List of results for each root node.

            var missing = aspectOrders.Where(p => !this.Contains(p.Item1)).Select(p => p.Item1);
            foreach (var m in missing)
            {
                Console.WriteLine(m);
            }
            var relations = (from t in aspectOrders
                             select GetNOrderRelations(t.Item2, this[t.Item1])).SelectMany(p => p).ToArray();

            foreach (var aspect in this)
            {
                var common = from r in relations
                    where r.Last() == aspect
                    select r;

                Dictionary<string, List<AspectNode[]>> aspectMatches = aspectOrders.Select(p => p.Item1).ToDictionary(p => p,
                    p => common.Where(q => q.First().Name == p).ToList());

                if (aspectMatches.Keys.Count != aspectOrders.Length || aspectMatches.Values.Any(p => p.Count == 0))
                {
                    continue;
                }

                foreach (var kvp in aspectMatches)
                {
                    foreach (var item in kvp.Value)
                    {
                        if (!result.ContainsKey(item.Last().Name))
                        {
                            result.Add(item.Last().Name, new Dictionary<string, List<AspectNode[]>>());
                        }

                        if (!result[item.Last().Name].ContainsKey(kvp.Key))
                        {
                            result[item.Last().Name].Add(kvp.Key, new List<AspectNode[]>());
                        }
                        result[item.Last().Name][kvp.Key].Add(item);
                    }
                }
            }


            return result;

        }

        public AspectNode[][] GetNOrderRelations(int order, AspectNode node)
        {
            List<List<AspectNode[]>> firstOrder = new List<List<AspectNode[]>>();

            if (order == 0)
            {
                return new AspectNode[][] { new AspectNode[] { node } };
            }

            var madeWithThisNode = (from a in this
                where a.Components.Contains(node)
                select a).ToArray();

            var combined = node.Components.Union(madeWithThisNode);
            foreach (AspectNode n in combined)
            {
                List<AspectNode[]> branch = new List<AspectNode[]>();
                var chain = GetNOrderRelations(order - 1, n);
                foreach (var c in chain)
                {
                    branch.Add(new AspectNode[] { node }.Concat(c).ToArray());
                }
                firstOrder.Add(branch);

            }

            return firstOrder.SelectMany(p => p.ToArray()).ToArray();
        }
    }
}
