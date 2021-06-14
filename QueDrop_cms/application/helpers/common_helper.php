<?php
/**
 * @param file-  input name
 * @param uploadpath-  where you want to upload
 * @param fname-  file name you want to give
 **@uses common fucntion for image upload
 */
function imageUpload($file, $upload_path, $fname)
{
    $CI = &get_instance();
    $file_type = array("image/jpeg", "image/png", "image/jpg");

    if (isset($_FILES[$file]["name"]) && $_FILES[$file]["name"] != "") {
        $str = explode(".", trim($_FILES[$file]["name"]));
        $temp = preg_split('/(?<=[a-z])(?=[0-9]+)/i', $str[0]);

        // if (!file_exists($upload_path)) {
        //     mkdir($upload_path, 0777, TRUE);
        //     chmod($upload_path, 0777);
        // }

        // upload image code
        $config['upload_path'] = $upload_path;
        $config['allowed_types'] = 'jpg|jpeg|png';
        $config['max_size'] = '54400'; // 2 MB
        $file_name = preg_replace('/[^A-Za-z0-9\-]/', '', $fname);

        if ($file_name == "") {
            $file_name = date("Ymd_his");
        }

        $ext = end($str);
        $config['file_name'] = $file_name;
        //$config['overwrite'] = TRUE;
        $CI->load->library('upload', $config);
        $CI->upload->initialize($config);

        if (!$CI->upload->do_upload($file)) {
            $data = $CI->upload->display_errors();

            $response['msg'] = 'error';
            $response['path'] = $data;
        } else {
            $new_filename = $file_name . '.' . $ext;
            $path = $new_filename;
            $response['msg'] = "success";
            $response['path'] = $path;
        }
    } else {
        $response['msg'] = "success";
        $response['path'] = '';
    }

    return $response;
}


/**
 * @param $file
 * @param $upload_path
 * @return mixed
 */
function imageUploadMultiple($file, $upload_path)
{
    $CI = &get_instance();
    $file_type = array("image/jpeg", "image/png", "image/jpg");

    if (isset($_FILES[$file]["name"]) && $_FILES[$file]["name"] != "") {
        if (!is_dir($upload_path)) {
            mkdir($upload_path, 0777, TRUE);
        }

        // upload image code
        $config['upload_path'] = $upload_path;
        $config['allowed_types'] = 'jpg|jpeg|png';
        $config['max_size'] = '54400'; // 2 MB
        $config['encrypt_name'] = TRUE;
        $config['overwrite'] = TRUE;
        $CI->load->library('upload', $config);
        $CI->upload->initialize($config);

        if (!$CI->upload->do_upload($file)) {
            $data = $CI->upload->display_errors();
            $msg = $data;
            $response['msg'] = $msg;
            $response['path'] = '';
        } else {
            $image_name = $CI->upload->data();
            $path = $image_name['file_name'];
            $response['msg'] = "success";
            $response['path'] = $path;
        }
    } else {
        $response['msg'] = "success";
        $response['path'] = '';
    }

    return $response;
}

/**
 * @return array
 */
function genderList()
{
    $CI = &get_instance();
    $genderList = $CI->common->sql_select(TBL_CATEGORIES, 'category_name', null, null);
    $genderObj = [];
    foreach ($genderList as $list) {
        $genderObj[] = $list['category_name'];
    }
    return $genderObj;
}


/**
 * @return array
 */
function lens_shape()
{
    $CI = &get_instance();
    $lensShapeList = $CI->common->sql_select(TBL_LENS_SHAPES, 'lens_shape', null, null);
    $lensShapeObj = [];
    foreach ($lensShapeList as $list) {
        $lensShapeObj[] = $list['lens_shape'];
    }
    return $lensShapeObj;
}

/**
 * @return array
 */
function frame_type()
{
    $CI = &get_instance();
    $frameTypeList = $CI->common->sql_select(TBL_FRAME_TYPES, 'frame_type', null, null);
    $frameTypeObj = [];
    foreach ($frameTypeList as $list) {
        $frameTypeObj[] = $list['frame_type'];
    }
    return $frameTypeObj;
}

/**
 * @return array
 */
function glass_category()
{
    $CI = &get_instance();
    $categoryList = $CI->common->sql_select(TBL_GLASS_CATEGORIES, 'glass_category_name', null, null);
    $categoryObj = [];
    foreach ($categoryList as $list) {
        $categoryObj[] = $list['glass_category_name'];
    }
    return $categoryObj;
}


/**
 * @param $message
 * @return mixed
 */
function responseError($message)
{
    $response['ResponseCode'] = 0;
    $response['ResponseMessage'] = $message;
    return json_encode($response);
}


/**
 * @param $data
 * @param $message
 * @return mixed
 */
function responseWithData($message, $data)
{
    $response['ResponseCode'] = 1;
    $response['ResponseMessage'] = $message;
    $response['data'] = $data;
    return json_encode($response);
}

/**
 * @param $message
 * @return mixed
 */
function responseSuccess($message)
{
    $response['ResponseCode'] = 1;
    $response['ResponseMessage'] = $message;
    return json_encode($response);
}