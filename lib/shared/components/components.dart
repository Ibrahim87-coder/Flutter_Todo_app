import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity ,
  Color background = Colors.blue,
  bool isUpperCase = true,
  double radius = 0.0,
  required VoidCallback function,
  required String text
})=>Container(
  width: width,
  height: 40.0,
  child: MaterialButton(
    onPressed: function,
    child: Text(
      isUpperCase ? text.toUpperCase(): text,
      style:  const TextStyle(
          color:Colors.white
      ),
    ),
  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: background,
  ),
);

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType keyboardType,
  Function(String)? onSubmit,
  Function(String)? onChange,
  Function? onTap,
  required String? Function(String?)? validate,
  bool isPassword = false,
  required String labelText ,
  required IconData prefix,
  IconData? suffix,
  VoidCallback? suffixPressed,
  bool isClickable =true,
}) => TextFormField(
  controller: controller,
  keyboardType: keyboardType,
  obscureText: isPassword,
  onFieldSubmitted: onSubmit,
  onChanged: onChange,
  validator: validate,
  onTap: ()
  {
    onTap!();
  },
  decoration:  InputDecoration(
    labelText: labelText,
    enabled: isClickable,
    border: const OutlineInputBorder(),
    prefixIcon: Icon(prefix),
    suffixIcon: suffix!= null ? IconButton(
        onPressed:suffixPressed,
        icon: Icon(suffix)) : null,

  ),
);

Widget buildTaskItem(Map model,context)=>Dismissible(
key: Key(model['id'].toString()),
  child:   Padding(

    padding: const EdgeInsets.all(20.0),

    child: Row(

      children:

      [

        CircleAvatar(

          radius: 40.0,

          child: Text('${model['time']}'),

        ),

        const SizedBox(

          width: 20.0,

        ),

        Expanded(

          child: Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

          Text('${model['title']}',

                style: const TextStyle(

                    fontSize: 18.0,

                    fontWeight: FontWeight.bold

                ),

              ),

    Text('${model['date']}',

                style: const TextStyle(

                  color: Colors.grey,

                ),

              ),

            ],

          ),

        ),

        const SizedBox(

          width: 20.0,

        ),

        IconButton(onPressed: ()

        {

          AppCubit.get(context).updateData(status: 'done', id: model['id']);

        },

            icon: const Icon(Icons.check_circle,color: Colors.green,)),

        IconButton(onPressed: (){

          AppCubit.get(context).updateData(status: 'archive', id: model['id']);



        }, icon: const Icon(Icons.archive,color: Colors.black45,)),



      ],

    ),

  ),
  onDismissed: (direction)
  {
AppCubit.get(context).deleteData(id:model['id']);
  },
);

Widget tasksBuilder({
  required List<Map> tasks
})=> ConditionalBuilder(
condition:tasks.isNotEmpty ,
builder: (BuildContext context) => ListView.separated(
itemBuilder: (context, index) =>
buildTaskItem(tasks[index], context),
separatorBuilder: (context, index) => Padding(
padding: const EdgeInsetsDirectional.only(start: 20.0),
child: Container(
width: double.infinity,
height: 1.0,
color: Colors.grey[300],
),
),
itemCount: tasks.length),
fallback: (context)=>Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center ,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Icon(Icons.menu,
size: 100.0,
color: Colors.grey,),
Text(
'No Tasks Yet, Please Add Some Tasks',
style: TextStyle(
fontSize: 18.0,
fontWeight: FontWeight.bold,
color: Colors.grey),
)
],
),
),
);