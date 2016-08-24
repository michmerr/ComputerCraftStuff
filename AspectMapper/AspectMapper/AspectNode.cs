using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AspectMapper
{
    public class AspectNode
    {
        public AspectNode()
        {
            Components = new AspectNodeSet();
        }

        public AspectNode(string name) : this()
        {
            Name = name;
        }

        public AspectNode(string name, IEnumerable<AspectNode> components)
        {
            Name = name;
            Components = new AspectNodeSet(components);
        }
        public string Name { get; set; }

        public AspectNodeSet Components { get; private set; }

    }
}
