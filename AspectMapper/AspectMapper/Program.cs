using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AspectMapper
{
    class Program
    {

        static void Main(string[] args)
        {
            AspectNodeSet nodes = AspectNodeSet.Load("aspects.txt");

            var result = nodes.GetCommonNodes(args.Select(p =>
            {
                var q = p.Split(':');
                return new Tuple<string, int>(q[0], Convert.ToInt32(q[1]));
            }).ToArray());

            foreach (var r in result)
            {
                Console.WriteLine(r.Key);
                foreach (var a in r.Value)
                {
                    Console.WriteLine(" " + a.Key);
                    foreach (var chain in a.Value)
                    {
                        Console.WriteLine("   " + string.Join(",", chain.Select(p => p.Name)));
                    }
                }
            }
        }
    }
}
