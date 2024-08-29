import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_api/youtube_api.dart';


import '../blocs/VideoPageBloc.dart';
import '../utils/universal_variables.dart';

class VideoSearchPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => VideoPageBloc(), child: VideoSearch());
  }
}


class VideoSearch extends StatefulWidget {

  @override
  State<VideoSearch> createState() => _VideoSearchState();
}

class _VideoSearchState extends State<VideoSearch> {

  final TextEditingController searchCtrl = TextEditingController();
  late VideoPageBloc videoPageBloc;



  @override
  Widget build(BuildContext context) {
    videoPageBloc = Provider.of<VideoPageBloc>(context);
    return  Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: UniversalVariables.whiteLightColor,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              createSearchBar(),
              Expanded(
                child: Container(
                  color: Colors.white10,
                  child: buildSuggestions(videoPageBloc.query),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query) {
    return Expanded(
      child: ListView.builder(
        itemCount: videoPageBloc.searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              'https://img.youtube.com/vi/${videoPageBloc.searchResults[index]["id"]}/maxresdefault.jpg',
              fit: BoxFit.cover,
            ),
            onTap: () {
              // Handle video selection
            },
          );
        },
      ),
    );
  }

  createSearchBar() {
    return Container(
      margin: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: UniversalVariables.whiteColor,
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onChanged: (search) {
                videoPageBloc.setQuery(search);
              },
              controller: searchCtrl,
              cursorColor: Colors.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  hintText: "Search..."),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: UniversalVariables.orangeColor,
                ),
                onPressed: () => videoPageBloc.searchVideos(videoPageBloc.query)
                ),
          ),
        ],
      ),
    );
  }

}

