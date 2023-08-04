import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomSearchTextField extends StatelessWidget {
  const CustomSearchTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(

          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white,),
              borderRadius: BorderRadius.circular(
                12,
              )
          ),
          focusedBorder:  OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white,),
              borderRadius: BorderRadius.circular(
                12,
              )
          ),
          hintText: 'Search',
          suffixIcon: IconButton(
            onPressed: () {},
            icon: const Opacity(opacity: .8,
                child: Icon(FontAwesomeIcons.magnifyingGlass)),
          )),
    );
  }
}
