<!--
Copyright 2026 Pablo Ochendrowitsch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

# SDLC & Software Engineering — Bibliographic References

Works are divided into two sections: those whose concepts are directly applied or explicitly named in the framework documents (RATIONALE.md, process decisions, agent definitions), and additional reference material that informs the problem space but is not part of the framework's operating logic.

---

## Works Referenced in the Framework

### Process Methodology

**Crystal Methods**
- Cockburn, A. — *Crystal Clear: A Human-Powered Methodology for Small Teams* (2004), Addison-Wesley
- Cockburn, A. — *Agile Software Development: The Cooperative Game* (2nd ed., 2006), Addison-Wesley

*Applied as:* The four-profile classification system (Casual/Commercial/Critical/Vital) is Cockburn's criticality scale with plain-language names. The "cooperative game" metaphor anchors the human-in-the-middle model. Human cognitive load reduction as a design goal is a Crystal principle.

**Extreme Programming (XP)**
- Beck, K., Andres, C. — *Extreme Programming Explained: Embrace Change* (2nd ed., 2004), Addison-Wesley
- Beck, K. — *Test-Driven Development: By Example* (2002), Addison-Wesley

*Applied as:* XP is the dominant methodology in the execution and verification phases. TDD (red/green/refactor) is a mandatory Builder practice. Simple design and the system metaphor inform Casual-profile architecture. Fast feedback loops within a cycle are XP-derived.

**Scrum**
- Schwaber, K., Sutherland, J. — *The Scrum Guide* (2020), Scrum.org *(definitive reference)*

*Applied as:* Scrum's empirical process control is the model for the Methodologist's retrospective at every Demo Sign-off. The transparency/inspection/adaptation loop is how the swarm re-calibrates between cycles.

**Shape Up**
- Singer, R. — *Shape Up: Stop Running in Circles and Ship Work that Matters* (2019), Basecamp *(free at basecamp.com/shapeup)*

*Applied as:* Appetite over estimate — the human provides direction and boundaries; the swarm fills in the details. The iterative approximation principle (DEC-0009) draws directly from this framing.

**Lean Software Development**
- Poppendieck, M. & T. — *Lean Software Development: An Agile Toolkit* (2003), Addison-Wesley

*Applied as:* Eliminate waste — waiting for perfect information is waiting. Last responsible moment — defer decisions until they must be made. Both principles shape the iterative approximation design goal and the `[DEFERRED]` flag in the Auditor.

**Unified Process (RUP)**
- Kruchten, P. — *The Rational Unified Process: An Introduction* (3rd ed., 2003), Addison-Wesley

*Applied as:* Architecture-centric decomposition, risk-first prioritization, and milestone quality gates are RUP influences in the decomposition phase and gate structure.

---

### Requirements and Domain Design

**Domain-Driven Design**
- Evans, E. — *Domain-Driven Design: Tackling Complexity in the Heart of Software* (2003), Addison-Wesley

*Applied as:* Ubiquitous language — the Analyst's Brief defines the vocabulary that all agents and the Nexus use. Domain model as the source of class names, method names, and docstring language in the scaffold and codebase.

**Behavior-Driven Development**
- North, D. — "Introducing BDD" (2006), *Better Software Magazine*

*Applied as:* Given/When/Then structure used by the Verifier for Demo Scripts and acceptance test cases.

---

### Software Engineering Practices

**Refactoring**
- Fowler, M. — *Refactoring: Improving the Design of Existing Code* (2nd ed., 2018), Addison-Wesley

*Applied as:* The Builder applies named refactoring techniques from Fowler's catalog (Extract Function, Rename Variable, Move Function, Replace Conditional with Polymorphism, Introduce Parameter Object) in the refactor step of red/green/refactor.

**Clean Code and SOLID**
- Martin, R.C. — *Clean Code* (2008), Prentice Hall

*Applied as:* Clean Code discipline governs all Builder implementation: meaningful names, small functions, single responsibility. SOLID principles (enforced at Commercial and above) define what a defect at the design level means.

**Pragmatic Programmer**
- Hunt, A., Thomas, D. — *The Pragmatic Programmer* (20th anniversary ed., 2019), Addison-Wesley

*Applied as:* YAGNI — do not implement what the current task does not require. Fail Fast — surface errors at the earliest possible point. Orthogonality — coupling between components is a defect, not a convenience. All three are always-on Builder practices.

**Design by Contract**
- Meyer, B. — *Object-Oriented Software Construction* (2nd ed., 1997), Prentice Hall

*Applied as:* Preconditions, postconditions, and class invariants are required on all public methods at Critical and Vital profiles. The Scaffolder documents contracts in every method signature. Invariant violations are surfaced immediately, not caught and handled.

---

### Software Architecture

**Architectural Fitness Functions**
- Richards, M., Ford, N. — *Fundamentals of Software Architecture* (1st ed. 2020, 2nd ed. ~2024), O'Reilly

*Applied as:* The fitness function concept (any mechanism that provides an objective integrity assessment of an architectural characteristic) is the basis for the Architect's dual-use fitness functions — the same specification governs both development-time verification and production monitoring thresholds.

---

### Delivery and Operations

**Continuous Delivery**
- Humble, J., Farley, D. — *Continuous Delivery* (2010), Addison-Wesley

*Applied as:* The three CD philosophy models (Continuous Deployment, Continuous Delivery, Cycle-based) implemented by the DevOps agent are grounded in Humble and Farley's deployment pipeline model. The Go-Live gate's decoupling from Demo Sign-off reflects the "always-releasable" principle applied to business-decision releases.

**DORA Metrics**
- Forsgren, N., Humble, J., Kim, G. — *Accelerate: The Science of Lean Software and DevOps* (2018), IT Revolution

*Applied as:* DORA metrics (deployment frequency, lead time, change failure rate, recovery time) are a natural set of fitness functions for delivery pipeline health — cited in the fitness function design alongside architectural characteristics.

---

### Systems Thinking and Constraints

**Theory of Constraints**
- Goldratt, E. — *The Goal* (1984), North River Press

*Applied as:* In agentic systems, human cognitive bandwidth is the primary constraint — not execution speed. This frames the entire human gate design: protect the Nexus's attention, maximize agent autonomy within authorized scope.

**Cynefin**
- Snowden, D. — "A Leader's Framework for Decision Making" (2007), *Harvard Business Review*

*Applied as:* Complex domains require human sense-making at decision points. Probe-sense-respond: the iterative approximation principle (assume-and-flag, then refine) is a safe-to-fail probe strategy for the complex domain of requirements elicitation.

---

### Agentic AI Research

**Agent Architectures**
- Yao, S. et al. — "ReAct: Synergizing Reasoning and Acting in Language Models" (2022), arXiv:2210.03629
- Shinn, N. et al. — "Reflexion: Language Agents with Verbal Reinforcement Learning" (2023), arXiv:2303.11366

*Applied as:* ReAct is the foundational reasoning+acting loop underlying all agent execution in the swarm. Reflexion's self-correction via verbal reflection informs the iterate loop design.

**Multi-Agent SDLC Systems**
- Qian, C. et al. — "ChatDev: Communicative Agents for Software Development" (2023), arXiv:2307.07924
- Hong, S. et al. — "MetaGPT: Meta Programming for Multi-Agent Collaborative Framework" (2023), arXiv:2308.00352

*Applied as:* Primary prior art for agentic SDLC. ChatDev demonstrates the gap Nexus fills (no human checkpoints, no persistent state). MetaGPT demonstrates SOP-driven agent roles — the direct inspiration for the Nexus SDLC agent definition file format.

**Evaluation Benchmarks**
- Yang, J. et al. — "SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering" (2024), arXiv:2405.15793
- Jimenez, C. et al. — "SWE-bench: Can Language Models Resolve Real-World GitHub Issues?" (2023), arXiv:2310.06770

*Applied as:* SWE-bench is the primary external benchmark for evaluating framework task completion against real GitHub issues. SWE-agent is the published baseline to compare against.

**Safe Agent Design**
- Amodei, D. et al. — "Concrete Problems in AI Safety" (2016), arXiv:1606.06565

*Applied as:* Theoretical grounding for bounded blast radius — reward hacking and safe exploration risks motivate the tiered tool access model and the human gate structure.

---

### UX and Interaction Design (Designer agent)

- Garrett, J.J. — *The Elements of User Experience* (2nd ed., 2010), New Riders
  *Applied as:* The 5 Planes framework (Strategy, Scope, Structure, Skeleton, Surface) defines the Designer's scope and sequencing. The Analyst covers Strategy and Scope; the Designer covers Structure, Skeleton, and Surface.

- Cooper, A., Reimann, R., Cronin, D., Noessel, C. — *About Face: The Essentials of Interaction Design* (4th ed., 2014), Wiley
  *Applied as:* Goal-Directed Design — every screen exists to help a user role accomplish a goal. Persona methodology grounds user roles from the Brief into behavioral depth.

- Norman, D. — *The Design of Everyday Things* (revised ed., 2013), Basic Books
  *Applied as:* Mental models as design constraints. Affordances and mappings — especially critical for TUI key binding design. Error states as character-revealing moments.

- Weinschenk, S. — *100 Things Every Designer Needs to Know About People* (2nd ed., 2020), New Riders
  *Applied as:* Cognitive load as a budget — every choice on a screen spends from it. Progressive disclosure as load management.

- Yablonski, J. — *Laws of UX* (2020), O'Reilly
  *Applied as:* Hick's Law (more options = slower decisions) and Jakob's Law (users spend most time on other products — convention is free) as explicit design constraints.

- Krug, S. — *Don't Make Me Think, Revisited* (3rd ed., 2014), New Riders
  *Applied as:* Convention as the default; every departure transfers a learning cost to the user that must be justified.

- Gothelf, J., Seiden, J. — *Lean UX* (3rd ed., 2021), O'Reilly
  *Applied as:* Design decisions are hypotheses, not answers. At Commercial and above, the Designer records hypotheses explicitly so that Demo Sign-off feedback can confirm or refute them.

- Wathan, A., Schoger, S. — *Refactoring UI* (2018), self-published
  *Applied as:* Visual design conventions for GUI at Casual profile — the Builder applies Refactoring UI conventions when no Surface specification is required.

---

## Additional Reference Material

Works that informed the design space, represent the intellectual tradition behind the framework, or are relevant for future extensions — but are not directly applied in the current framework documents.

### Unified Process / RUP
- Jacobson, I., Booch, G., Rumbaugh, J. — *The Unified Software Development Process* (1999), Addison-Wesley
- Larman, C. — *Applying UML and Patterns* (3rd ed., 2004), Prentice Hall

### Extreme Programming (XP)
- Jeffries, R., Anderson, A., Hendrickson, C. — *Extreme Programming Installed* (2000), Addison-Wesley

### Scrum
- Schwaber, K., Beedle, M. — *Agile Software Development with Scrum* (2001), Prentice Hall
- Schwaber, K. — *Agile Project Management with Scrum* (2004), Microsoft Press
- Sutherland, J. — *Scrum: The Art of Doing Twice the Work in Half the Time* (2014), Crown Business

### Agile Manifesto and Scaled Agile
- Beck, K. et al. — *Manifesto for Agile Software Development* (2001), agilemanifesto.org
- Leffingwell, D. — *Agile Software Requirements* (2011), Addison-Wesley *(SAFe foundation)*
- Leffingwell, D. — *SAFe 5.0 Distilled* (2020), Addison-Wesley
- Larman, C., Vodde, B. — *Large-Scale Scrum (LeSS)* (2016), Addison-Wesley
- Larman, C., Vodde, B. — *Scaling Lean & Agile Development* (2008), Addison-Wesley

### Test-Driven and Acceptance Testing
- Freeman, S., Pryce, N. — *Growing Object-Oriented Software, Guided by Tests* (2009), Addison-Wesley
- Chelimsky, D. et al. — *The RSpec Book* (2010), Pragmatic Bookshelf
- Hendrickson, E. — *Explore It!* (2013), Pragmatic Bookshelf
- Adzic, G. — *Specification by Example* (2011), Manning

### Feature-Driven Development
- Palmer, S., Felsing, M. — *A Practical Guide to Feature-Driven Development* (2002), Prentice Hall
- Coad, P., Lefebvre, E., De Luca, J. — *Java Modeling in Color with UML* (1999), Prentice Hall

### Lean Startup and Hypothesis-Driven Design
- Ries, E. — *The Lean Startup* (2011), Crown Business
- Torres, T. — *Continuous Discovery Habits* (2021), Product Talk
- Poppendieck, M. & T. — *Implementing Lean Software Development* (2006), Addison-Wesley
- Womack, J., Jones, D. — *Lean Thinking* (1996), Simon & Schuster

### Kanban and Flow
- Anderson, D.J. — *Kanban: Successful Evolutionary Change for Your Technology Business* (2010), Blue Hole Press
- Reinertsen, D. — *The Principles of Product Development Flow* (2009), Celeritas
- Reinertsen, D. — *Managing the Design Factory* (1997), Free Press
- Little, J.D.C. — "A Proof for the Queuing Formula: L=λW" (1961), *Operations Research*

### Domain-Driven Design (Extended)
- Vernon, V. — *Implementing Domain-Driven Design* (2013), Addison-Wesley
- Vernon, V. — *Domain-Driven Design Distilled* (2016), Addison-Wesley
- Brandolini, A. — *Introducing EventStorming* (2021), Leanpub

### Microservices and Integration Architecture
- Richardson, C. — *Microservices Patterns* (2018), Manning
- Newman, S. — *Building Microservices* (2nd ed., 2021), O'Reilly
- Hohpe, G., Woolf, B. — *Enterprise Integration Patterns* (2003), Addison-Wesley

### DevOps
- Kim, G. et al. — *The Phoenix Project* (2013), IT Revolution Press
- Kim, G. et al. — *The DevOps Handbook* (2016), IT Revolution Press

### Continuous Integration / Trunk-Based Development
- Duvall, P., Matyas, S., Glover, A. — *Continuous Integration* (2007), Addison-Wesley
- Hammant, P. — *Trunk Based Development* (trunkbaseddevelopment.com)

### Software Architecture (Extended)
- Bass, L., Clements, P., Kazman, R. — *Software Architecture in Practice* (4th ed., 2021), Addison-Wesley
- Ford, N. et al. — *Software Architecture: The Hard Parts* (2021), O'Reilly

### Software Craftsmanship (Extended)
- Martin, R.C. — *The Clean Coder* (2011), Prentice Hall
- Martin, R.C. — *Clean Architecture* (2017), Prentice Hall
- McConnell, S. — *Code Complete* (2nd ed., 2004), Microsoft Press
- McConnell, S. — *Rapid Development* (1996), Microsoft Press
- Feathers, M. — *Working Effectively with Legacy Code* (2004), Prentice Hall

### Pair and Mob Programming
- Zuill, W., Meadows, K. — *Mob Programming: A Whole Team Approach* (2016), Leanpub

### Systems Thinking (Extended)
- Senge, P. — *The Fifth Discipline* (1990), Doubleday
- Stacey, R. — *Complex Responsive Processes in Organizations* (2001), Routledge

### Risk Management
- Boehm, B. — *Software Risk Management* (1989), IEEE Computer Society Press
- McConnell, S. — *Rapid Development* (1996), Microsoft Press

### Classical Foundations
- Brooks, F. — *The Mythical Man-Month* (1975, anniversary ed. 1995), Addison-Wesley
- Royce, W. — "Managing the Development of Large Software Systems" (1970), *Proceedings of IEEE WESCON*
- Boehm, B. — "A Spiral Model of Software Development and Enhancement" (1988), *IEEE Computer*
- DeMarco, T. — *Controlling Software Projects* (1982), Prentice Hall

### AI-Assisted Development
- Russell, S. — *Human Compatible: Artificial Intelligence and the Problem of Control* (2019), Viking
- Shanahan, M. — *The Technological Singularity* (2015), MIT Press
- Various — GitHub Copilot research papers (2022–2024), IEEE/ACM venues

### Agentic AI — Planning and Tool Use
- Wei, J. et al. — "Chain-of-Thought Prompting Elicits Reasoning in Large Language Models" (2022), arXiv:2201.11903
- Wang, L. et al. — "Plan-and-Solve Prompting" (2023), arXiv:2305.04091
- Zheng, Z. et al. — "CodeChain: Towards Modular Code Generation Through Chain of Self-Revisions" (2023), arXiv:2310.08992
- Jiang, X. et al. — "Self-Planning Code Generation with Large Language Models" (2023), arXiv:2303.06689
- Khot, T. et al. — "Decomposed Prompting" (2022), arXiv:2210.02406
- Shen, Y. et al. — "HuggingGPT" (2023), arXiv:2303.17580
- Schick, T. et al. — "Toolformer" (2023), arXiv:2302.04761
- Chen, M. et al. — "Evaluating Large Language Models Trained on Code" (2021), arXiv:2107.03374
- Guo, D. et al. — "DeepSeek-Coder" (2024), arXiv:2401.14196

### Agentic AI — Safety and Alignment
- Shen, T. et al. — "Large Language Model Alignment: A Survey" (2023), arXiv:2309.15025
- Weidinger, L. et al. — "Ethical and Social Risks of Harm from Language Models" (2021), arXiv:2112.04359
- Irving, G., Askell, A. — "AI Safety Needs Social Scientists" (2019), Distill

### Agentic AI — Surveys
- Wang, L. et al. — "A Survey on Large Language Model based Autonomous Agents" (2023), arXiv:2308.11432
- Xi, Z. et al. — "The Rise and Potential of Large Language Model Based Agents" (2023), arXiv:2309.07864
- Guo, T. et al. — "Large Language Model based Multi-Agents: A Survey" (2024), arXiv:2402.01680

### UX Psychology and Research (Extended)
- Johnson, J. — *Designing with the Mind in Mind* (3rd ed., 2020), Morgan Kaufmann
- Müller-Brockmann, J. — *Grid Systems in Graphic Design* (1981), Niggli
- Hall, E. — *Just Enough Research* (2nd ed., 2019), A Book Apart
- Knapp, J., Zeratsky, J., Kowitz, B. — *Sprint* (2016), Simon & Schuster
