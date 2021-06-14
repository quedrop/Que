<!-- Page header -->
<div class="page-header page-header-default">
  <div class="page-header-content">
    <div class="page-title">
      <h4>
        <span class="text-semibold">Store Payments</span>
      </h4>
    </div>
  </div>
  <div class="breadcrumb-line">
    <ul class="breadcrumb">
      <li>
        <a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
      </li>
      <li class="active">
        Store Payments
      </li>
    </ul>
  </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
  <!-- Panel -->
  <div class="panel panel-flat">
    
      <!-- Panel heading -->
      <div class="panel-heading">
        
          <!-- <a href="<?php echo base_url('admin/orders/add'); ?>" class="btn btn-primary"><?php _el('add_new'); ?><i class="icon-plus-circle2 position-right"></i></a> -->
        
        
        <!-- <a href="javascript:delete_selected();" class="btn btn-danger" id="delete_selected"><?php _el('delete_selected'); ?><i class=" icon-trash position-right"></i></a> -->
        
      </div>
      <!-- /Panel heading -->
    
    
    <!-- Listing table -->
    <div class="panel-body table-responsive">
      <table id="orders_table" class="table table-bordered table-striped">
        <thead>
          <tr>
            
            <th>
              <input type="checkbox" name="select_all" id="select_all" class="styled" onclick="select_all(this);" >
            </th>
            
            <th>Store Name</th>
            <th class="text-center"><?php _el('actions'); ?></th>
            
          </tr>
        </thead>
        <tbody>
          <?php foreach ($store as $key => $order) { ?>
          <tr>
            <td>
              <input type="checkbox" class="checkbox styled"  name="delete"  id="<?php  echo $order['store_id']; ?>">
            </td>
           
            <td><?php echo ucfirst($order['store_name']);?></td>
            <td class="text-center">
                <a data-popup="tooltip" data-placement="top"  title="<?php _el('view') ?>" href="<?php echo site_url('admin/payments/view_store/').$order['store_id']; ?>" id="<?php echo $order['store_id']; ?>" class="text-info">
                  <i class="icon-eye"></i>
                </a>
            </td>
            
          </tr>
          <?php } ?>
        </tbody>
      </table>      
    </div>
    <!-- /Listing table -->
  </div>
  <!-- /Panel -->
</div>
<!-- /Content area -->


<script type="text/javascript">
$(function() {

    $('#orders_table').DataTable({
        buttons: {
            dom: {
            button: {
                className: 'btn btn-default'
            }
            },
            buttons: [
            'copyHtml5',                
            'csvHtml5',
            'pdfHtml5'
            ]
        },
        'columnDefs': [ {
        'targets': [0], /* column index */
        'orderable': false, /* disable sorting */
        }],
         
    });

    //add class to style style datatable select box
    $('div.dataTables_length select').addClass('datatable-select');
 });



</script>