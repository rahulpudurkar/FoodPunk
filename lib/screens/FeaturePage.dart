import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';

import '../blocs/HomePageBloc.dart';
import '../widgets/foodTitleWidget.dart';

class FeaturePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => HomePageBloc(), child: SplitViewExample());
  }
}



class SplitViewExample extends StatefulWidget {
  @override
  State<SplitViewExample> createState() => _SplitViewExampleState();
}


class _SplitViewExampleState extends State<SplitViewExample> {
  late HomePageBloc homePageBloc;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      homePageBloc.getCurrentUser();
      homePageBloc.getCategoryFoodList();
      homePageBloc.getRecommendedFoodList();
    });
  }

  @override
  Widget build(BuildContext context) {
    homePageBloc = Provider.of<HomePageBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Feature Page'),
      ),
      body: SplitView(
        children: [
          Container(
            child: createPopularFoodList(),
          ),
          Container(
            child: createForYou(),
          ),
        ],
        viewMode: SplitViewMode.Vertical,
        indicator: SplitIndicator(viewMode: SplitViewMode.Vertical),
        activeIndicator: SplitIndicator(
          viewMode: SplitViewMode.Vertical,
          isActive: true,
        ),
        controller: SplitViewController(limits: [null, WeightLimit(max: 0.65, min: 0.2)]),
        onWeightChanged: (w) => print("Vertical $w"),
      ),
    );
  }

  createPopularFoodList() {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text(
              "Trending Foods",
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            height: 200.0,
            child: homePageBloc.popularFoodList.length == -1
                ? Center(child: Center(child: CircularProgressIndicator()))
                : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homePageBloc.popularFoodList.length,
                itemBuilder: (_, index) {
                  return FoodTitleWidget(
                    homePageBloc.popularFoodList[index],
                  );
                }),
          ),
        ],
      ),
    );
  }

  createForYou() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: EdgeInsets.symmetric(vertical: 20.0),
      child: homePageBloc.foodList.length == 0
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
          itemCount: homePageBloc.foodList.length,
          itemBuilder: (_, index) {
            return FoodTitleWidget(homePageBloc.foodList[index]);
          }),
    );
  }
}