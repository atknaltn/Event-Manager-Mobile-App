import 'package:flutter/material.dart';

class CorrelationRuleScreen extends StatefulWidget {
  @override
  _CorrelationRuleScreenState createState() => _CorrelationRuleScreenState();
}

class _CorrelationRuleScreenState extends State<CorrelationRuleScreen> {
  final _rules = Rule();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rule Builder'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              RuleWidget(
                rule: _rules,
                level: 0,
              ),
              ElevatedButton(
                child: Text('Calculate'),
                onPressed: () {
                  if (_rules != null)
                    print(_rules);
                  else
                    print("Rules are not defined");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RuleWidget extends StatefulWidget {
  final Rule rule;
  final int level;

  const RuleWidget({
    Key? key,
    required this.rule,
    required this.level,
  }) : super(key: key);

  @override
  _RuleWidgetState createState() => _RuleWidgetState();
}

class _RuleWidgetState extends State<RuleWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.level * 16.0),
          child: Row(
            children: [
              if (widget.rule != null)
                DropdownButton(
                  items: const [
                    DropdownMenuItem(
                      child: Text('AND'),
                      value: 'AND',
                    ),
                    DropdownMenuItem(
                      child: Text('OR'),
                      value: 'OR',
                    ),
                    DropdownMenuItem(
                      child: Text('Other'),
                      value: 'Other',
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      widget.rule.operator = value!;
                      if (value == 'AND' || value == 'OR') {
                        widget.rule.children.add(Rule(parent: widget.rule));
                      }
                    });
                  },
                ),
              if (widget.rule != null && (widget.rule.operator != null))
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      widget.rule.children.add(Rule(parent: widget.rule));
                    });
                  },
                ),
            ],
          ),
        ),
        if (widget.rule != null && widget.rule.children != null)
          for (var i = 0; i < widget.rule.children.length; i++)
            Padding(
              padding: EdgeInsets.only(left: widget.level * 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        widget.rule.children[i].parent!.children
                            .remove(widget.rule.children[i]);
                      });
                    },
                  ),
                  RuleWidget(
                    rule: widget.rule.children[i],
                    level: widget.level + 1,
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class Rule {
  String operator = "";
  List<Rule> children = [];
  Rule? parent;

  Rule({this.parent});
}
